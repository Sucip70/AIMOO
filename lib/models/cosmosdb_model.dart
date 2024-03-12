import 'dart:math';

import 'package:azure_cosmosdb/azure_cosmosdb.dart';

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