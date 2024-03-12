import 'package:azure_cosmosdb/azure_cosmosdb.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minimal/constants/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minimal/models/cosmosdb_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final CosmosDbServer cosmosDB;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.cosmosDB
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
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }
}

