import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minimal/constants/constants.dart';

class AIChat {
  final String id;
  final String photoUrl;
  final String nickname;
  final String system;
  final String endpoint;
  final String key;
  final bool isPublic;
  final String temperature;
  final String freqPenalty;
  final String presPenalty;
  final String topP;
  final String maxTokens;
  final List<String>? stop;
  final bool isSearchIndex;
  final String? searchEndpoint;
  final String? searchKey;
  final String? searchIndex;
  final List<String>? group;

  const AIChat({required this.id, 
    required this.photoUrl, 
    required this.nickname,
    required this.system,
    required this.endpoint,
    required this.isPublic,
    required this.key,
    required this.temperature,
    required this.freqPenalty,
    required this.presPenalty,
    required this.topP,
    required this.maxTokens,
    required this.stop,
    required this.isSearchIndex,
    required this.searchEndpoint,
    required this.searchKey,
    required this.searchIndex,
    required this.group
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.systemMessage: system,
      FirestoreConstants.endpoint: endpoint,
      FirestoreConstants.key: key,
      FirestoreConstants.isPublic: isPublic,
      FirestoreConstants.temperature: temperature,
      FirestoreConstants.frequencyPenalty: freqPenalty,
      FirestoreConstants.presencePenalty: presPenalty,
      FirestoreConstants.topP: topP,
      FirestoreConstants.maxTokens: maxTokens,
      FirestoreConstants.stop: stop,
      FirestoreConstants.isSearchIndex: isSearchIndex,
      FirestoreConstants.searchEndpoint: searchEndpoint,
      FirestoreConstants.searchKey: searchKey,
      FirestoreConstants.searchIndex: searchIndex,
      FirestoreConstants.group: group
    };
  }

  factory AIChat.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String nickname = "";
    String system = "";
    String endpoint = "";
    String key = "";
    bool isPublic = false;
    String temperature = "";
    String freqPenalty = "";
    String presPenalty = "";
    String topP = "";
    String maxTokens = "";
    List<String>? stop = [];
    bool isSearchIndex = false;
    String? searchEndpoint;
    String? searchKey;
    String? searchIndex;
    List<String>? group = [];

    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}
    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (e) {}
    try {
      system = doc.get(FirestoreConstants.systemMessage);
    } catch (e) {}
    try {
      endpoint = doc.get(FirestoreConstants.endpoint);
    } catch (e) {}
    try {
      isPublic = doc.get(FirestoreConstants.isPublic);
    } catch (e) {}
    try {
      key = doc.get(FirestoreConstants.key);
    } catch (e) {}
    try {
      freqPenalty = doc.get(FirestoreConstants.frequencyPenalty);
    } catch (e) {}
    try {
      temperature = doc.get(FirestoreConstants.temperature);
    } catch (e) {}
    try {
      presPenalty = doc.get(FirestoreConstants.presencePenalty);
    } catch (e) {}
    try {
      topP = doc.get(FirestoreConstants.topP);
    } catch (e) {}
    try {
      maxTokens = doc.get(FirestoreConstants.maxTokens);
    } catch (e) {}
    try {
      final st = doc.get(FirestoreConstants.stop);
      stop = (st as List).map((item) => item as String).toList();
    } catch (e) {}
    try {
      isSearchIndex = doc.get(FirestoreConstants.isSearchIndex);
    } catch (e) {}
    try {
      searchEndpoint = doc.get(FirestoreConstants.searchEndpoint);
    } catch (e) {}
    try {
      searchIndex = doc.get(FirestoreConstants.searchIndex);
    } catch (e) {}
    try {
      searchKey = doc.get(FirestoreConstants.searchKey);
    } catch (e) {}
    try {
      final st = doc.get(FirestoreConstants.group);
      group = (st as List).map((item) => item as String).toList();
    } catch (e) {}

    return AIChat(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
      system: system,
      endpoint: endpoint,
      key: key,
      isPublic: isPublic,
      freqPenalty: freqPenalty,
      temperature: temperature,
      presPenalty: presPenalty,
      topP: topP,
      maxTokens: maxTokens,
      stop: stop,
      isSearchIndex: isSearchIndex,
      searchEndpoint: searchEndpoint,
      searchKey: searchKey,
      searchIndex: searchIndex,
      group: group
    );
  }
}
