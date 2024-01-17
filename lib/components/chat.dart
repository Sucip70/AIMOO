import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minimal/constants/constants.dart';
import 'package:minimal/models/bot.dart';
import 'package:minimal/providers/providers.dart';
import 'package:minimal/widgets/widgets.dart';
import 'package:minimal/models/models.dart';
import 'package:minimal/pages/pages.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ChatBox extends StatefulWidget{
  static const String name = 'list';

  const ChatBox({super.key});

  @override
  ChatBoxState createState() => ChatBoxState();
}

class ChatBoxState extends State<ChatBox> with SingleTickerProviderStateMixin{
  double minW = 200;
  double maxW = 500;
  late Animation<double> animation;
  late AnimationController controller;
  String currentUserId = "b4v5lwbwyvSWpw39lyiOfohVQw13";
  String currentBotID = "xRtT3Mh6cGbGc0vtQpOq";
  BotCustom bot = BotCustom();

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";

  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final AuthProvider authProvider = context.read<AuthProvider>();
  Arguments arg = new Arguments(peerId: '', peerAvatar: '', peerNickname: '', peerSystem: '', peerEndpoint: '', peerIsPublic: false, peerKey: '', peerTemperature: '', peerFreqPenalty: '', peerPresPenalty: '', peerTopP: '', peerMaxTokens: '', peerIsSearchIndex: false, peerMode: '');

  @override
  void initState(){
    super.initState();

    controller =  AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: minW, end: maxW).animate(controller)
    ..addListener(() {
      setState(() {
           // The state that has changed here is the animation object's value.
      });
    });

    groupChatId = "${currentUserId}-${currentBotID}";

    // AIChat userChat = AIChat.fromDocument("document");
    arg = Arguments(
      peerId: currentBotID,
      peerAvatar: '',
      peerNickname: 'BOT',
      peerSystem: 'You are an AI assistant that helps people find information.',
      peerEndpoint: 'https://maniac.openai.azure.com/openai/deployments/gpt-35-turbo/chat/completions?api-version=2023-07-01-preview&api-key=1db64539bd6b45299d2aaf10bd67634c',
      peerKey: '',
      peerIsPublic: false,
      peerTemperature: '0.73',
      peerFreqPenalty: '0.0',
      peerPresPenalty: '0.0',
      peerTopP: '0.95',
      peerMaxTokens: '800',
      peerStop: null,
      peerIsSearchIndex: false,
      peerSearchEndpoint: '',
      peerSearchIndex: '',
      peerSearchKey: '',
      peerMode: 'bot'
    );
  }

  @override
  Widget build(BuildContext context){
    return Container(
      width: animation.value,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border.fromBorderSide(BorderSide.none),
        boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, 3), // changes position of shadow
        ),],
        borderRadius:const  BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
      ),
      child: ExpansionTile(
        shape: const BeveledRectangleBorder(side: BorderSide(color: Color.fromARGB(0, 0, 0, 0))),
        collapsedShape: const BeveledRectangleBorder(side: BorderSide(color: Color.fromARGB(0, 0, 0, 0))),
        onExpansionChanged: (value) {
          if(animation.value == minW){
            controller.forward();
          }else{
            controller.reverse();
          }
        },
        title: const Row(
            children: [
              Icon(Icons.chat, size: 22),
              Text(
                " Contact Us",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)
              ),
            ],
        ),
        children: <Widget>[
          SizedBox(
            height: 400,
            child: SafeArea(
              child: WillPopScope(
                onWillPop: onBackPress,
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        // List of messages
                        buildListMessage(),

                        // Input content
                        buildInput(),
                      ],
                    ),

                    // Loading
                    buildLoading()
                  ],
                ),
              ),
            ),
          ),

        ],
      ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getChatStream(groupChatId, _limit),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.length > 0) {
                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return Center(child: Text("No message here yet..."));
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorConstants.themeColor,
                    ),
                  );
                }
              },
            )
          : Center(
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            ),
    );
  }

    Widget buildLoading() {
    return Positioned(
      child: isLoading ? LoadingView() : SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)), color: Colors.white),
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 20),
              child: TextField(
                onSubmitted: (value) {
                  sendMessage(textEditingController.text);
                },
                style: TextStyle(color: ColorConstants.primaryColor, fontSize: 15),
                controller: textEditingController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: ColorConstants.greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  sendMessage(textEditingController.text);
                },
                color: ColorConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),);
  }

  void sendMessage(String message){
    if(_startConversation == 120){
      startConversation();
    }
    var list = quests;
    list.add(textEditingController.text);
    quests = list;
    if(_startResponse == 5){
      startResponse(textEditingController.text);
    }
    setState(() {
      quests = List<String>.from(list);
      _startResponse = 5;
      _startConversation = 120;
      if(bot.chatStatus == 2 && message.trim() == "5"){
        _conversationTimer?.cancel();
        _conversationTimer = null;
      }
    });
    onSendMessage(message, TypeMessage.text);
  }

  Future<bool> onBackPress() {
    // if (isShowSticker) {
    //   setState(() {
    //     isShowSticker = false;
    //   });
    // } else {
      chatProvider.updateDataFirestore(
        FirestoreConstants.pathUserCollection,
        currentUserId,
        {FirestoreConstants.chattingWith: null},
      );
      Navigator.pop(context);
    // }

    return Future.value(false);
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        // Right (my message)
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            messageChat.type == TypeMessage.text
                // Text
                ? Container(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(color: ColorConstants.greyColor2, borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                    child: Text(
                      messageChat.content,
                      style: const TextStyle(color: ColorConstants.primaryColor),
                    ),
                  )
                : messageChat.type == TypeMessage.image
                    // Image
                    ? Container(
                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullPhotoPage(
                                  url: messageChat.content,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                          child: Material(
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              messageChat.content,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: ColorConstants.greyColor2,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: ColorConstants.themeColor,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) {
                                return Material(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    // Sticker
                    : Container(
                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                        child: Image.asset(
                          'images/${messageChat.content}.gif',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
          ],
        );
      } else {
        // Left (peer message)
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(18),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(
                            arg.peerAvatar,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: ColorConstants.themeColor,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return const Icon(
                                Icons.account_circle,
                                size: 35,
                                color: ColorConstants.greyColor,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(width: 35),
                  messageChat.type == TypeMessage.text
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          constraints: const BoxConstraints(maxWidth: 300),
                          decoration:
                              BoxDecoration(color: ColorConstants.primaryColor, borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.only(left: 10),
                          child: Text(
                            messageChat.content,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: TextButton(
                                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                                child: Material(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder:
                                        (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: ColorConstants.greyColor2,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: ColorConstants.themeColor,
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, object, stackTrace) => Material(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullPhotoPage(url: messageChat.content),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                              child: Image.asset(
                                'images/${messageChat.content}.gif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                ],
              ),

              // Time
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm')
                            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(messageChat.timestamp))),
                        style: TextStyle(color: ColorConstants.greyColor, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                      margin: EdgeInsets.only(left: 50, top: 5, bottom: 5),
                    )
                  : SizedBox.shrink()
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(content, type, groupChatId, currentUserId, arg);
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: ColorConstants.greyColor);
    }
  }


  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) == currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) != currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Timer? _conversationTimer;
  int _startConversation = 120;
  void startConversation() {
    const oneSec = Duration(seconds: 1);
    _conversationTimer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_startConversation == 0) {
          chatProvider.send(bot.end, groupChatId, arg.peerId, currentUserId, TypeMessage.text);
          chatProvider.send("${bot.close}\n${bot.greet()}", groupChatId, arg.peerId, currentUserId, TypeMessage.text);
          setState(() {
            bot.chatStatus = 0;
            quests = [];
            timer.cancel();
            _startConversation = 120;
          });
        } else {
          setState(() {
            _startConversation--;
          });
        }
      },
    );
  }

  List<String> quests = [];
  Timer? _responseTimer;
  int _startResponse = 5;
  void startResponse(String content) {
    const oneSec = Duration(seconds: 1);
    _responseTimer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_startResponse == 0) {
          String quest = "";
          for(var i=0; i<quest.length; i++){
            quest += "${quests[i]}. ";
          }
          BotCustom res = chatProvider.getResponse(content, groupChatId, currentUserId, arg, bot, TypeMessage.text);
          setState(() {
            bot = res;
            quests = [];
            timer.cancel();
            _startResponse = 5;
          });
        } else {
          setState(() {
            _startResponse--;
          });
        }
      },
    );
  }
}

