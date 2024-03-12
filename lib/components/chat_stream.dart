import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimal/components/components.dart';
import 'package:minimal/constants/constants.dart';
import 'package:minimal/models/models.dart';
import 'package:minimal/providers/chat_provider.dart';

class StreamChat extends StatefulWidget {
  StreamChat(
      {super.key,
      required this.currentUserId,
      required this.groupChatId,
      required this.stream,
      required this.listScrollController,
      required this.chatProvider,
      required this.isTyping,
      required this.startConversation, 
      required this.onTimesChanged,
      required this.streamController});

  final String groupChatId;
  final String currentUserId;
  Stream<QuerySnapshot>? stream;
  final ScrollController listScrollController;
  final ChatProvider chatProvider;
  bool isTyping;
  int startConversation;
  final ValueChanged<int> onTimesChanged;
  StreamController<String> streamController;

  @override
  State<StreamChat> createState() => _StreamChatState();
}

class _StreamChatState extends State<StreamChat> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  List<MessageChat> listMessage = [];
  bool hasRate = false;
  double rating = 0;
  String timeRating = "";
  int _limit = 10;

  @override
  bool get wantKeepAlive => true;

  late AnimationController _controller;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 2),
    );

    _textAnimation = IntTween(
      begin: 0,
      end: 180,
    ).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Flexible(
      child: widget.groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: widget.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = [];
                  for(var doc in snapshot.data!.docs){
                    listMessage.add(MessageChat.fromDocument(doc));
                  }
                  // return ScrollListener(
                  //   controller: widget.listScrollController,
                  //   threshold: 0.9,
                  //   builder: (context, controller) {
                      int len = listMessage.length + 2;

                      return ListView.builder(
                        itemCount: len,
                        reverse: true,
                        padding: const EdgeInsets.all(20),
                        itemBuilder: (context, index) {
                          return chatBuilder(index);
                        },
                      );
                    // }
                    // loadNext: () {
                    //   if (snapshot.data?.docs.length == _limit) {
                    //     setState(() {
                    //       _limit += 10;
                    //       widget.stream = widget.chatProvider
                    //           .getChatStream(widget.groupChatId, _limit);
                    //     });
                    //   }
                  //   },
                  // );
                } else {
                  return const Center(child: Text("No message here yet..."));
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            ),
    );
  }


  Widget buildChatStream(){
    return StreamBuilder(
      stream: widget.streamController.stream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          String mm = snapshot.data ?? "";
          if(widget.isTyping){
            String type = "Typing";
            type += List.generate(_textAnimation.value % 5, (index) => " .")
                .join("");
            if(mm.isNotEmpty)mm+="\n\n";
            mm += type;
          }else{
            return SizedBox.shrink();
          }
          return leftMessage(MessageChat(
            idFrom: "", idTo: "", timestamp: "0", content: mm));
        }else if(widget.isTyping){
          String type = "Typing";
          type += List.generate(_textAnimation.value % 4, (index) => ".")
              .join("");
          return leftMessage(MessageChat(idFrom: "", idTo: "", timestamp: "0", content: type));
        }
        return SizedBox.shrink();
      });
  }

  Widget chatBuilder(int index) {
    String tmpTime = "";

    if (0 == index) {
      return buildChatStream();
    } else if (1 == index) {
      if (widget.startConversation <= 180) {
        return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    TextButton(
                        onPressed: () {
                          widget.onTimesChanged(0);
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                          Colors.grey.withOpacity(0.2),
                        )),
                        child: const Text(
                          "Tidak",
                          style: TextStyle(color: ColorConstants.primaryColor),
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                        onPressed: () {
                          widget.onTimesChanged(300);
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                          Colors.grey.withOpacity(0.2),
                        )),
                        child: const Text("Ada",
                            style:
                                TextStyle(color: ColorConstants.primaryColor)))
                  ])
                ]));
      } else {
        return const SizedBox.shrink();
      }
    }

    MessageChat messageChat = listMessage[index - 2];
    if (tmpTime == "") tmpTime = messageChat.timestamp;
    if (timeRating.compareTo(messageChat.timestamp) > 0 && timeRating != "") {
      bool flag = false;
      if (index == 2) {
        flag = true;
      } else if (timeRating.compareTo(tmpTime) < 0) {
        flag = true;
      }
      tmpTime = messageChat.timestamp;
      if (flag) {
        return Column(
          children: [
            buildItem(index - 2, messageChat),
            ratingArea(),
          ],
        );
      } else {
        return buildItem(index - 2, messageChat);
      }
    } else {
      tmpTime = messageChat.timestamp;
      return buildItem(index - 2, messageChat);
    }
  }

  Widget buildItem(int index, MessageChat messageChat) {
    if (messageChat.idFrom == widget.currentUserId) {
      // Right (my message)
      return Container(
          margin: const EdgeInsets.only(
            // bottom: isLastMessageRight(index) ? 20 : 10,
            bottom: 10,
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                          color: ColorConstants.greyColor2,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        messageChat.content,
                        style: const TextStyle(
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
                  child: Text(
                    DateFormat('dd MMM kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(messageChat.timestamp))),
                    style: const TextStyle(
                        color: ColorConstants.greyColor,
                        fontSize: 12,
                        fontStyle: FontStyle.italic),
                  ),
                )
              ]));
    } else {
      // Left (peer message)
      return leftMessage(messageChat);
    }
  }

  Widget leftMessage(MessageChat messageChat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Material(
                borderRadius: const BorderRadius.all(
                  Radius.circular(18),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  'assets/images/chatbot-data.png',
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,
                ),
              )
              ,
              Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                constraints: const BoxConstraints(maxWidth: 300),
                decoration: BoxDecoration(
                    color: ColorConstants.primaryColor,
                    borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.only(left: 10),
                child: Text(
                  messageChat.content,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),

          // Time
          messageChat.idFrom.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(left: 50, top: 5, bottom: 5),
                  child: Text(
                    DateFormat('dd MMM kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(messageChat.timestamp))),
                    style: const TextStyle(
                        color: ColorConstants.greyColor,
                        fontSize: 12,
                        fontStyle: FontStyle.italic),
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget ratingArea() {
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Material(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(18),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.asset(
                      'assets/images/chatbot-data.png',
                      width: 35,
                      height: 35,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      constraints: const BoxConstraints(maxWidth: 250),
                      decoration: BoxDecoration(
                          color: ColorConstants.primaryColor,
                          borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.only(left: 10),
                      child: !hasRate
                          ? Column(
                              children: [
                                const Text(
                                  "Rate this conversation",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                StarRating(
                                  rating: rating,
                                  onRatingChanged: (rating) =>
                                      setState(() => this.rating = rating),
                                  color: const Color(0xFFCFFF20),
                                  size: 30,
                                ),
                                if (rating > 0)
                                  FilledButton(
                                    onPressed: () {
                                      widget.chatProvider
                                          .sendRating(rating,
                                              widget.groupChatId, timeRating)
                                          .then((value) {
                                        setState(() {
                                          if (value) {
                                            hasRate = true;
                                          }
                                        });
                                      });
                                    },
                                    style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.white70)),
                                    child: const Text("Submit",
                                        style: TextStyle(
                                            color:
                                                ColorConstants.primaryColor)),
                                  )
                              ],
                            )
                          : const Text(
                              "Thanks for caring!",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ))
                ],
              ),
            ]));
  }
}
