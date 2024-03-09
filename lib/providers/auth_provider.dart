import 'package:azure_cosmosdb/azure_cosmosdb.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimal/constants/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minimal/models/cosmosdb_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  // final FirebaseFirestore firebaseFirestore;
  final CosmosDbServer cosmosDB;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.cosmosDB
    // required this.firebaseFirestore,
  });

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreConstants.id);
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn && prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;
      final database = await cosmosDB.databases.openOrCreate(
        AppConstants.database,
        throughput: CosmosDbThroughput.minimum,
      );

      final indexingPolicy = IndexingPolicy(indexingMode: IndexingMode.consistent)
      ..excludedPaths.add(IndexPath('/*'))
      ..includedPaths.add(IndexPath('/"due-date"/?'))
      ..compositeIndexes.add([
        IndexPath('/label', order: IndexOrder.ascending),
        IndexPath('/"due-date"', order: IndexOrder.descending)
      ]);

      final collection = await database.containers.openOrCreate("users", partitionKey: PartitionKeySpec.id, indexingPolicy: indexingPolicy);
      collection.registerBuilder<Users>(Users.fromJson);

      if (firebaseUser != null) {
        final users = await collection.query<Users>(
          Query('SELECT * FROM c WHERE c.id = @id', params: {'@id': firebaseUser.uid}),
        );

        if (users.isEmpty) {
          // Writing data to server because here is a new user
          await collection.add(Users(
            firebaseUser.uid,
            firebaseUser.displayName ?? 'unknown',
            createdDate: DateTime.now(),
            photoUrl: firebaseUser.photoURL
          ));

          // Write data to local storage
          User? currentUser = firebaseUser;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(FirestoreConstants.nickname, currentUser.displayName ?? "");
          await prefs.setString(FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
        } else {
          // Write data to local
          Users user = users.first;
          await prefs.setString(FirestoreConstants.id, user.id);
          await prefs.setString(FirestoreConstants.nickname, user.nickname);
          await prefs.setString(FirestoreConstants.photoUrl, user.photoURL ?? '');
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  void handleException() {
    _status = Status.authenticateException;
    notifyListeners();
  }

  Future<void> handleSignOut() async {
    _status = Status.uninitialized;
    // await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }

  String getMasterKey(String verb, String url, String type, String version){
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    var u8 = base64Decode(AppConstants.masterKey);
    var key = String.fromCharCodes(u8);
    var dateUtc = getDateUTC(); //utc

    var urlRegExp = RegExp(r'/^https?:\/\/.*\.documents\.azure\.com(?::\d+)?(?:\/([^\/]+)(?:\/([^\/]+)?)?)+$/i');
    var parsedUrl = urlRegExp.stringMatch(url);
    // Get resource type from URL
    String resourceType = parsedUrl?[1] ?? "";
    // Get resource ID from URL, if it is not present, we are getting undefined.
    String resourceId = parsedUrl?[2] ?? "";

    var resourceLinkPattern = RegExp(r'/^https?:\/\/.*\.documents\.azure\.com(?::\d+)?\/(.*)$/i');
    var parsedResourceLink = resourceLinkPattern.stringMatch(url);
    String rlink = parsedResourceLink?[1].toString() ?? "";

    String resourceLink = rlink[rlink.length-1] == "/"?
        rlink.substring(rlink.length-1):
        parsedResourceLink?[1] ?? "";
    // Resource Link will be just: dbs/MyCollection
    if(resourceId == "") { // Resource Id not provided
        // We need to cut last part to left just Resource Id
        resourceLink = resourceLink.substring(0, resourceLink.lastIndexOf('/'));
    }
    // See: https://docs.microsoft.com/en-us/rest/api/cosmos-db/access-control-on-cosmosdb-resources
    var text = (verb ?? "").toLowerCase() + "\n" +
                (resourceType ?? "").toLowerCase() + "\n" +
                (resourceLink ?? "") + "\n" +
                dateUtc.toLowerCase() + "\n\n";
    // Build key to authorize request.

    var hmacSha256 = Hmac(sha256, utf8.encode(key));
    var signature = hmacSha256.convert(utf8.encode(text));
    // Code key as base64 to be sent.
    var signature_base64 = stringToBase64.encode(signature.toString());
    // Build autorization token and encode it as URI to be sent.
    var authorizationToken = Uri.encodeFull("type=" + type + "&ver=" + version + "&sig=" + signature_base64);
    return authorizationToken;
  }

  String getDateUTC(){
    var dateTime = DateTime.now();
    var val      = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(dateTime);
    var offset   = dateTime.timeZoneOffset;
    var hours    = offset.inHours > 0 ? offset.inHours : 1; // For fixing divide by 0

    if (!offset.isNegative) {
      val = val +
          "+" +
          offset.inHours.toString().padLeft(2, '0') +
          ":" +
          (offset.inMinutes % (hours * 60)).toString().padLeft(2, '0');
    } else {
      val = val +
          "-" +
          (-offset.inHours).toString().padLeft(2, '0') +
          ":" +
          (offset.inMinutes % (hours * 60)).toString().padLeft(2, '0');
    }
    return val;
  }

}

