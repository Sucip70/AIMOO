import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:azure_cosmosdb/azure_cosmosdb.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:minimal/constants/constants.dart';
import 'package:minimal/models/bot.dart';
import 'package:minimal/models/models.dart';
import 'package:minimal/models/openai/request_api.dart';
import 'package:minimal/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:dart_openai/dart_openai.dart';

class ChatProvider {
  final SharedPreferences prefs;
  final CosmosDbServer cosmosDbServer;
  final fs.FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider(
      {required this.cosmosDbServer,
      required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage});

  Patch setPatch(Map<String, dynamic> data) {
    var patch = Patch();
    data.forEach((key, value) {
      patch.replace(key, value);
    });
    return patch;
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

  void send(String message, String groupChatId, String from, String to) {
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
            return content;
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

  Stream<OpenAIStreamChatCompletionModel> getAIStream( String message, Arguments arg, BotCustom bot) {
    OpenAI.apiKey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlhSdmtvOFA3QTNVYVdTblU3Yk05blQwTWpoQSIsImtpZCI6IlhSdmtvOFA3QTNVYVdTblU3Yk05blQwTWpoQSJ9.eyJhdWQiOiJodHRwczovL21hbmFnZW1lbnQuY29yZS53aW5kb3dzLm5ldC8iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9mYTUzYTUyNi1iOTVlLTQzMmYtYjZmNS00NWI3MDQ4YmMyMTcvIiwiaWF0IjoxNzEwMTY1NjMxLCJuYmYiOjE3MTAxNjU2MzEsImV4cCI6MTcxMDE3MDc2NSwiYWNyIjoiMSIsImFpbyI6IkFUUUF5LzhXQUFBQVFpSmlyS3dWeEZERXUrbm9jOStlR3VvTUdrK2krRzVRZkI0NDZXS3p5YUMwbnpjTjF1Q2RMRms5N3NESU44V0ciLCJhbXIiOlsicHdkIiwicnNhIl0sImFwcGlkIjoiYjY3N2MyOTAtY2Y0Yi00YThlLWE2MGUtOTFiYTY1MGE0YWJlIiwiYXBwaWRhY3IiOiIwIiwiZGV2aWNlaWQiOiI2ZWM0YWMwNS0wZjliLTRkYjItYjVhZC1jMmEwZTczNTI3NWMiLCJmYW1pbHlfbmFtZSI6IlN1Y2lwdG8iLCJnaXZlbl9uYW1lIjoiQWhtYWQiLCJncm91cHMiOlsiMGVjNjgwNDUtNDJlYy00Mjc3LWJhYzYtMTkwYmE1ZGVkYTU3IiwiZGZlNjZmNjEtYmE5Ni00OGNmLTg5MTgtMzVhZTJmZWQxYWZjIiwiYzA2ZmQ5YWUtNjQxOS00OTZmLWI3ZTMtZWRmYzY3OGRhMGRlIl0sImlkdHlwIjoidXNlciIsImlwYWRkciI6IjE4MC4yNDIuMTI5Ljg5IiwibmFtZSI6IkFobWFkIFN1Y2lwdG8iLCJvaWQiOiIxODdiM2Y1Ny1jMWFjLTQxMWEtYjM2Mi0xMjNmNGIzMTkwYzQiLCJvbnByZW1fc2lkIjoiUy0xLTUtMjEtMzY3NjE3OTA5OS0xMDY3MTgzNjY0LTE3OTQzNTE3MjUtMTIyMSIsInB1aWQiOiIxMDAzMjAwMjM5NTQ4QjFEIiwicmgiOiIwLkFWTUFKcVZULWw2NUwwTzI5VVczQkl2Q0YwWklmM2tBdXRkUHVrUGF3ZmoyTUJOVEFIcy4iLCJzY3AiOiJ1c2VyX2ltcGVyc29uYXRpb24iLCJzdWIiOiI5VVUyS2hoN0Z0OGdZaEpMV255ZHJTZVR5RWY5b3lTQkdhUkx2aHk0bkJvIiwidGlkIjoiZmE1M2E1MjYtYjk1ZS00MzJmLWI2ZjUtNDViNzA0OGJjMjE3IiwidW5pcXVlX25hbWUiOiJhc3VjaXB0b0BpbnRpa29tLmNvLmlkIiwidXBuIjoiYXN1Y2lwdG9AaW50aWtvbS5jby5pZCIsInV0aSI6Imw4QlVzbVRtYkVXMnJIZjFXalJXQUEiLCJ2ZXIiOiIxLjAiLCJ3aWRzIjpbIjExNjQ4NTk3LTkyNmMtNGNmMy05YzM2LWJjZWJiMGJhOGRjYyIsImI3OWZiZjRkLTNlZjktNDY4OS04MTQzLTc2YjE5NGU4NTUwOSJdLCJ4bXNfY2FlIjoiMSIsInhtc190Y2R0IjoxMzg5ODc3ODc2fQ.TPtg_8tBRoI71kq6XPCD3bz-KVqhqe28HTnh7Oh6bRqkdff8aEmcSzEEg7P1hwJvU5MpJYDtbpAHZi5mWrVeTsTIh4g0KSJtH8vEee8kDDqbrFKlPS4wrAhxSWEwIVzvSuJ2HiItVYnKs9Vs8uwKVhrmT6Al7MmcWKd06YOuikzYNpSr5WC-0T0QGIowsqXy78JkciJ3TYzBuhCnkiYL8IdyWd4TCeoZ4jEOfWQlVMbneEB4SskP2PLu-PTa8lrjSOKDT90gPR-kRNiMabijCwj_4H83C3pXrJbxv9DqMMRYw3DgQPouoYGUyzo6z4xxmo6MEuNty26JlTXZ_fsSag";

    return OpenAI.instance.chat.createStream(
      url: arg.peerEndpoint,
      model: "gpt-35-turbo",
      messages2: [
        {
          "role": "system", 
          "content": arg.peerSystem
        },{
          "role": "user", 
          "content": "apa itu bca"
        },
      ],
      frequencyPenalty: 0.3,
      maxTokens: 300,
      n: 1,
      presencePenalty: 0.6,
      // seed: 310,
      temperature: 0.2,
      topP: 0.9,
      searchEndpoint: arg.peerSearchEndpoint,
      searchIndex: arg.peerSearchIndex,
      searchKey: arg.peerSearchKey
    ).asBroadcastStream();
  }

  String removeUnconditional(String content) {
    return content.replaceAll(RegExp(r'\[doc[0-9]+\]'), '');
  }

  Future<bool> clearChat(String groupChatId)async{
    fs.DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId);
    
    fs.DocumentSnapshot res = await documentReference.get();
    if(res.exists){
      await documentReference.delete();
    }

    await fs.FirebaseFirestore.instance.runTransaction((myTransaction) async {
        await myTransaction.delete(documentReference);
    });
    return true;
  }
}

