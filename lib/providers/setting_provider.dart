import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:minimal/constants/firestore_constants.dart';
import 'package:minimal/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SettingProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  SettingProvider({
    required this.prefs,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  String? getPref(String key) {
    return prefs.getString(key);
  }

  Future<bool> setPref(String key, String value) async {
    return await prefs.setString(key, value);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }

  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  
  Future<void> createAI(Arguments arg){
    String id = getRandomString(20);
    return firebaseFirestore.collection(FirestoreConstants.pathAICollection)
      .doc(id).set({
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        FirestoreConstants.endpoint: arg.peerEndpoint,
        FirestoreConstants.frequencyPenalty : arg.peerFreqPenalty,
        FirestoreConstants.id : id,
        FirestoreConstants.isPublic : arg.peerIsPublic,
        FirestoreConstants.key : arg.peerKey,
        FirestoreConstants.maxTokens : arg.peerMaxTokens,
        FirestoreConstants.nickname : arg.peerNickname,
        FirestoreConstants.photoUrl : arg.peerAvatar,
        FirestoreConstants.presencePenalty : arg.peerPresPenalty,
        FirestoreConstants.stop : arg.peerStop,
        FirestoreConstants.systemMessage : arg.peerSystem,
        FirestoreConstants.temperature : arg.peerTemperature,
        FirestoreConstants.topP : arg.peerTopP,
        FirestoreConstants.isSearchIndex : arg.peerIsSearchIndex,
        FirestoreConstants.searchEndpoint : arg.peerSearchEndpoint,
        FirestoreConstants.searchIndex : arg.peerSearchIndex,
        FirestoreConstants.searchKey : arg.peerSearchKey,
        FirestoreConstants.group: arg.peerGroup
      });
  }

  Future<void> removeAI(String aiID){
    return firebaseFirestore.collection(FirestoreConstants.pathAICollection)
      .doc(aiID).delete();
  }
}
