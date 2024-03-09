import 'dart:math';

import 'package:azure_cosmosdb/azure_cosmosdb.dart';
import 'package:minimal/constants/constants.dart';

class CosmosDB{
  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

class Users extends BaseDocumentWithEtag {
  Users._(
    this.id,
    this.nickname,
    this.createdDate,
    this.photoURL
  );

  Users(
    String? id,
    String nickname, {
    DateTime? createdDate,
    String? photoUrl,
  }) : this._(id ?? CosmosDB().getRandomString(20), nickname, createdDate, photoUrl);

  @override
  final String id;

  String nickname;
  DateTime? createdDate;
  String? photoURL;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'createdDate': createdDate?.toUtc().toIso8601String(),
        'photoUrl': photoURL
      };

  static Users fromJson(Map json) {
    final users = Users._(
      json['id'],
      json['nickname'],
      DateTime.tryParse(json['createdDate'] ?? '')?.toLocal(),
      json['photoUrl']
    );
    users.setEtag(json);
    return users;
  }
}

class Chatbot extends BaseDocumentWithEtag {
  Chatbot._(
    this.id,
    this.createdDate,
    this.endpoint,
    this.frequencyPenalty,
    this.maxTokens,
    this.nickname,
    this.presencePenalty,
    this.searchEndpoint,
    this.searchIndex,
    this.searchKey,
    this.stop,
    this.system,
    this.temperature,
    this.topP,
  );

  Chatbot(
    String endpoint,
    double frequencyPenalty,
    int maxTokens,
    String nickname,
    double presencePenalty,
    String system,
    double temperature,
    double topP,
    {
    DateTime? createdDate,
    String? searchEndpoint,
    String? searchIndex,
    String? searchKey,
    List<String>? stop
  }) : this._(CosmosDB().getRandomString(20), 
    createdDate, endpoint, frequencyPenalty, maxTokens, nickname, presencePenalty, searchEndpoint, searchIndex, searchKey
    , stop, system, temperature, topP);

  @override
  final String id;

  DateTime? createdDate;
  String endpoint;
  double frequencyPenalty;
  int maxTokens;
  String nickname;
  double presencePenalty;
  String? searchEndpoint;
  String? searchIndex;
  String? searchKey;
  List<String>? stop;
  String system;
  double temperature;
  double topP;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdDate': createdDate?.toUtc().toIso8601String(),
        'endpoint' : endpoint,
        'frequency_penalty' : frequencyPenalty,
        'max_tokens' : maxTokens,
        'nickname': nickname,
        'presence_penalty' : presencePenalty,
        'search_endpoint' : searchEndpoint,
        'search_index' : searchIndex,
        'search_key' : searchKey,
        'stop' : stop,
        'system' : system,
        'temperature' : temperature,
        'top_p' : topP
      };

  static Chatbot fromJson(Map json) {
    final chatbot = Chatbot._(
      json['id'],
      DateTime.tryParse(json['createdDate'] ?? '')?.toLocal(),
      json['endpoint'],
      double.parse(json['frequency_penalty']),
      int.parse(json['max_tokens']),
      json['nickname'],
      double.parse(json['presence_penalty']),
      json['search_endpoint'],
      json['search_index'],
      json['search_key'],
      json['stop'] as List<String>,
      json['system'],
      double.parse(json['temperature']),
      double.parse(json['top_p'])
    );
    chatbot.setEtag(json);
    return chatbot;
  }
}

class Messages extends BaseDocumentWithEtag {
  Messages._(
    this.id,
    this.messages,
  );

  Messages(String id,
    List<ContentMessage> messages
    ) : this._(id,
     messages
     );

  @override
  final String id;

  List<ContentMessage> messages;
  // ListMessage messages;

  @override
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> msg = [];
    for (var m in messages) {
      msg.add({
        "content" : m.content,
        "idFrom" : m.idFrom,
        "idTo" : m.idTo,
        "timestamp" : m.timestamp,
        "type" : m.type
      });
    }
    return {
      'id': id,
      'messages': msg,
      };
    }

  static Messages fromJson(Map json) {
    List<ContentMessage> tmp = [];
    
    if( json['messages'] != null){
      for (var e in json['messages']) {
        tmp.add(ContentMessage(
          content: e['content'], 
          idFrom: e['idFrom'], 
          idTo: e['idTo'], 
          timestamp: e['timestamp'], 
          type: e['type']));
      }
    }
    final users = Messages._(
      json['id'],
      tmp,
    );
    users.setEtag(json);
    return users;
  }
}

class ListMessage{
  late List<ContentMessage> list;

  ListMessage({required this.list});

  ListMessage.fromJson(List<Map<String, dynamic>> json){
    list = <ContentMessage>[];
    json.forEach((element) {
      list.add(ContentMessage.fromJson(element));
    });
  }

  List<Map<String, dynamic>> toJson() {
    List<Map<String, dynamic>> res = [];
    for(var i in list){
      res.add({
        FirestoreConstants.idFrom: i.idFrom,
        FirestoreConstants.idTo: i.idTo,
        FirestoreConstants.timestamp: i.timestamp,
        FirestoreConstants.content: i.content,
        FirestoreConstants.type: i.type,
      });
    }
    return res;
  }
}

class ContentMessage{
  final String content;
  final String idFrom;
  final String idTo;
  final String timestamp;
  final int type;

  ContentMessage({required this.content, required this.idFrom, required this.idTo, required this.timestamp, required this.type});

  ContentMessage.fromJson(Map<String, dynamic> json):
    content = json['content'] as String,
    idFrom = json['idFrom'] as String,
    idTo = json['idTo'] as String,
    timestamp = json['timestamp'] as String,
    type = json['type'] as int;
}