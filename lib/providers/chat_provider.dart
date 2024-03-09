import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:azure_cosmosdb/azure_cosmosdb.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:minimal/constants/constants.dart';
import 'package:minimal/models/bot.dart';
import 'package:minimal/models/models.dart';
import 'package:minimal/models/openai/requestAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatProvider {
  final SharedPreferences prefs;
  final CosmosDbServer cosmosDbServer;
  final fs.FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  final CosmosDbContainer cosmosDbContainer;

  ChatProvider(
      {required this.cosmosDbServer,
      required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage,
      required this.cosmosDbContainer});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Patch setPatch(Map<String, dynamic> data) {
    var patch = Patch();
    data.forEach((key, value) {
      patch.replace(key, value);
    });
    return patch;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) async {
    final db = await cosmosDbServer.databases.open(AppConstants.database);
    final col = await db.containers.openOrCreate(
      collectionPath,
      partitionKey: PartitionKeySpec.id,
    );

    final obj = await col.query(
      Query('SELECT * FROM c WHERE c.id = @id', params: {'@id': docPath}),
    );

    await col.patch(obj.first, setPatch(dataNeedUpdate));
  }

  Stream<fs.QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<BaseDocument> getChatBot(String id) async {
    final db = await cosmosDbServer.databases.open(AppConstants.database);
    final col = await db.containers.openOrCreate(
      FirestoreConstants.pathBotCollection,
      partitionKey: PartitionKeySpec.id,
    );

    final obj = await col.query(
      Query('SELECT * FROM c WHERE c.id = @id', params: {'@id': id}),
    );
    return obj.first;
  }

  void sendMessage(String content, String groupChatId, String currentUserId, Arguments arg) {
    send(content, groupChatId, currentUserId, arg.peerId);
  }

  Future<bool> sendRating(
      double rate, String groupChatId, String timeStamp) async {
    final db = await cosmosDbServer.databases.open(AppConstants.database);
    final col = await db.containers.openOrCreate(
      "rating",
      partitionKey: PartitionKeySpec.id,
    );
    col.registerBuilder<Rate>(Rate.fromJson);
    await col.add(Rate(groupChatId, rate, timeStamp));
    return true;
  }

  Future<BotCustom> getResponse(String content, String groupChatId,
      String currentUserId, Arguments arg, BotCustom bot) async {
    if (content.isEmpty) return bot;

    await getAIResponse(content, arg, bot).then((String result) {
      if (bot.chatStatus == 0) {
        send(bot.greet(), groupChatId, arg.peerId, currentUserId);
        bot.chatStatus = 1;
      }
      send(result, groupChatId, arg.peerId, currentUserId);
      return bot;
    });
    return bot;
  }

  void send( String message, String groupChatId, String from, String to) {
    fs.DocumentReference documentReference2 = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat2 = MessageChat(
      idFrom: from,
      idTo: to,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message
    );

    fs.FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference2,
        messageChat2.toJson(),
      );
    });
  }

  Future<String> getAIResponse(
      String message, Arguments arg, BotCustom bot) async {
    try {
      Map<String, dynamic> body = arg.azureRequest(message);
      var encode = json.encode(arg.peerIsSearchIndex
          ? RequestIndexer.fromJson(body)
          : Request.fromJson(body));
      final response = await http.post(Uri.parse(arg.peerEndpoint),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'api-key ${arg.peerKey}'
          },
          body: encode);

      if (response.statusCode == 200) {
        var decode = json.decode(response.body);
        if (arg.peerIsSearchIndex) {
          var message = decode["choices"].first["messages"];
          var content = "";
          for (var i = 0; i < message.length; i++) {
            if (message[i]["role"] == "assistant") {
              content = message[i]["content"];
            }
          }
          if (content != "") {
            if (content.contains(bot.unwanted)){
              return bot.unwantedRes;
            }
            content = removeUnconditional(content);
            return "${content}";
          } else {
            return bot.unwantedRes;
          }
        } else {
          var message = decode["choices"].first["message"];
          return "${message["content"]}";
        }
      } else {
        return bot.error;
      }
    } catch (e) {
      return bot.error;
    }
  }

  String removeUnconditional(String content) {
    return content.replaceAll(RegExp(r'\[doc[0-9]+\]'), '');
  }
}

