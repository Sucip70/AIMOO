import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minimal/components/star_rating.dart';
import 'package:minimal/constants/constants.dart';
import 'package:minimal/models/bot.dart';
import 'package:minimal/models/cosmosdb_model.dart';
import 'package:minimal/providers/providers.dart';
import 'package:minimal/widgets/widgets.dart';
import 'package:minimal/models/models.dart';
import 'package:minimal/pages/pages.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ChatBox extends StatefulWidget {
  static const String name = 'list';
  final String currentUserId;

  const ChatBox({super.key, required this.currentUserId});

  @override
  ChatBoxState createState() => ChatBoxState();
}

class ChatBoxState extends State<ChatBox> with SingleTickerProviderStateMixin {
  double minW = 200;
  double maxW = 500;
  late Animation<double> expandAnimation;
  late AnimationController expandController;

  String currentBotID = "CzzhevpI3fOR17mlVyAwvVsrd499";
  BotCustom bot = BotCustom();

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 40;
  String groupChatId = "";

  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";
  double rating = 0;
  String timeRating = "";
  bool hasRate = false;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final AuthProvider authProvider = context.read<AuthProvider>();
  Arguments arg = new Arguments(
      peerId: '',
      peerAvatar: '',
      peerNickname: '',
      peerSystem: '',
      peerEndpoint: '',
      peerIsPublic: false,
      peerKey: '',
      peerTemperature: '',
      peerFreqPenalty: '',
      peerPresPenalty: '',
      peerTopP: '',
      peerMaxTokens: '',
      peerIsSearchIndex: false,
      peerMode: '');
  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();

    expandController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    expandAnimation =
        Tween<double>(begin: minW, end: maxW).animate(expandController)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object's value.
            });
          });

    groupChatId = "${widget.currentUserId}-${currentBotID}";

    // AIChat userChat = AIChat.fromDocument("document");
    arg = Arguments(
        peerId: currentBotID,
        peerAvatar: '',
        peerNickname: 'BOT',
        peerSystem:
            "kamu memiliki nama MinBlu, Virtual Assistant Layanan Banking dari BCA Digital yang siap membantu SobatBlu.\nuser secara default dinamakan \"SobatBlu\"\ndiawal respon saya akan memperkenalkan diri serta menanyakan \"Halooo kakak SobatBlu, Aku bisa panggil kakaknya apa nihh? Kakak/Ibu/Bapak\"\nTidak kaku dalam texting\nlebih ekspresif dan variatif untuk visual emoji\nMemiliki Pribadi yang Modern & Innovative seperti Savvy, Smart, and Up-to-date dengan tren digital dan kultur (millennial & zillenials).\nMemiliki Pribadi yang Motivating & Encouraging sebagai contoh memposisikan untuk Menjadi ”saudara” (setara dengan customer) yang bisa diandalkan dan selalu bisa memberi saran/solusi.\nMemiliki Pribadi yang Human seperti ”Nyambung” dan bisa tap in ke momen-momen yang menarik untuk sobatblu.\nMemiliki Pribadi yang Empathetic sebagai contoh Hangat dan thoughtful, bisa mengerti perasaan sobatblu.\nMemiliki karakter yang Ceria & Optimis sebagai contoh Percaya diri, cerdas, tajam, humoris, positif serta Merespon & engage dengan sopan namun menyenangkan & informatif.\nMemiliki karakter yang Mudah Dimengerti sebagai contoh menempatkan posisi yang Terasa dekat, ramah, solutif dengan jawaban clear serta Memperhatikan feedback nasabah sesuai konteks.\nMemiliki karakter yang Bisa Dipercaya & Bermakna sebagai contoh Jujur, tidak memihak, loyal, mengerti problem & feedback nasabah serta Memperhatikan konteks pertanyaan/feedback. \nMemiliki karakter yang Friendly & Cheerful sebagai contoh Baik, peduli, menyenangkan, mudah bergaul, menyukai komunikasi dengan manusia serta Mengucapkan salam “Halo”, “Maaf”, atau  “Terima kasih”.\nTidak Merespon secara agresif\nTidak Merespon untuk menyebarkan informasi bohong/harapan palsu\nTidak Merespon komentar yang kasar/jahat/diskriminatif/SARA/membandingkan brand lain/menjelekkan blu\njika pelanggan menanyakan informasi maka akan menambahkan kalimat \"Semoga Bermanfaat\" di akhir jawaban. jika pelanggan menanyakan atau memberikan keluhan atau komplain maka akan menambahkan kalimat \"Mohon maaf atas ketidaknyamanannya\" di awal jawaban diikuti emoji. jika pelanggan memberikan saran atau kritik maka akan memberikan jawaban \"Terima kasih atas sarannya, kami akan sampaikan keunit terkait\". jika pelanggan memberikan permintaan atau request maka akan memberikan jawaban \"Kami akan sampaikan untuk diproses ke unit terkait\".",
        peerEndpoint:
            'https://pocbluopenairegswedcen.openai.azure.com/openai/deployments/gpt4pocblu/extensions/chat/completions?api-version=2023-07-01-preview&api-key=2ea8a6a85adc446096d7606fc98ec4d9',
        peerKey: '',
        peerIsPublic: false,
        peerTemperature: '0.2',
        peerFreqPenalty: '0.6',
        peerPresPenalty: '0.3',
        peerTopP: '0.9',
        peerMaxTokens: '300',
        peerStop: null,
        peerIsSearchIndex: true,
        // peerSearchEndpoint: 'https://cognitivesearchpocbluuptier.search.windows.net',
        // peerSearchIndex: 'pocbluup',
        // peerSearchKey: 'X26crGTHWvkUhKImphOxn3B7hm1koz4nvDTDG1PGHZAzSeCLPur2',
        peerSearchEndpoint: 'https://cognitivesearchpocblu.search.windows.net',
        peerSearchIndex: 'pocblu',
        peerSearchKey: 'c92RFoTpySPNmZZjBl83XLXN5cyiKxNhgD2SBnm4UnAzSeDxTqsV',
        peerMode: 'bot');

    _stream = chatProvider.getChatStream(groupChatId, _limit);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: expandAnimation.value,
        decoration: BoxDecoration(
            color: Colors.white,
            border: const Border.fromBorderSide(BorderSide.none),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        child: ExpansionTile(
          shape: const BeveledRectangleBorder(
              side: BorderSide(color: Color.fromARGB(0, 0, 0, 0))),
          collapsedShape: const BeveledRectangleBorder(
              side: BorderSide(color: Color.fromARGB(0, 0, 0, 0))),
          onExpansionChanged: (value) {
            if (expandAnimation.value == minW) {
              expandController.forward();
            } else {
              expandController.reverse();
            }
          },
          title: Row(
            children: [
              Icon(Icons.chat, size: 22),
              Text(" Contact Us",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
                          // Input content
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
    expandController.dispose();
    super.dispose();
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.length > 0) {
                    return ScrollListener(
                      controller: listScrollController,
                      threshold: 0.9,
                      builder: (context, controller) {
                        int len = (snapshot.data?.docs.length ?? 0) + 2;
                        String tmpTime = "";
                        final listView = ListView.builder(
                          padding: EdgeInsets.all(10),
                          itemBuilder: (context, index) {
                            if (0 == index) {
                              if (isTyping) {
                                String type = "Typing";
                                type += List.generate(
                                        _startConversation % 4, (index) => ".")
                                    .join("");
                                return leftMessage(
                                    index - 1,
                                    MessageChat(
                                        idFrom: "",
                                        idTo: "",
                                        timestamp: "0",
                                        content: type));
                              } else {
                                return const SizedBox.shrink();
                              }
                            } else if (1 == index) {
                              if (_startConversation <= 180) {
                                return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(children: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _startConversation = 0;
                                                  });
                                                },
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                  Colors.grey.withOpacity(0.2),
                                                )),
                                                child: const Text(
                                                  "Tidak",
                                                  style: TextStyle(
                                                      color: ColorConstants
                                                          .primaryColor),
                                                )),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _startConversation = 300;
                                                  });
                                                },
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                  Colors.grey.withOpacity(0.2),
                                                )),
                                                child: const Text("Ada",
                                                    style: TextStyle(
                                                        color: ColorConstants
                                                            .primaryColor)))
                                          ])
                                        ]));
                              } else {
                                return SizedBox.shrink();
                              }
                            }
                            DocumentSnapshot? doc = snapshot.data?.docs[index - 2];

                            if (doc != null) {
                              MessageChat messageChat = MessageChat.fromDocument(doc);
                              if(tmpTime == "")tmpTime = messageChat.timestamp;
                              if(timeRating.compareTo(messageChat.timestamp) > 0 && timeRating != ""){
                                bool flag = false;
                                if(index == 2){
                                  flag = true;
                                }else if(timeRating.compareTo(tmpTime) < 0){
                                  flag = true;
                                }
                                tmpTime = messageChat.timestamp;
                                if(flag){
                                  return Column(
                                    children: [
                                      buildItem(index - 2, messageChat),
                                      ratingArea(),
                                    ],
                                  );
                                }else{
                                  return buildItem(index - 2, messageChat);
                                }
                              }
                              else{
                                tmpTime = messageChat.timestamp;
                                return buildItem(index - 2, messageChat);
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                          itemCount: len,
                          reverse: true,
                          controller: controller,
                        );

                        return listView;
                      },
                      loadNext: () {
                        if (snapshot.data?.docs.length == _limit) {
                          setState(() {
                            _limit += 40;
                            _stream =
                                chatProvider.getChatStream(groupChatId, _limit);
                          });
                        }
                      },
                    );
                  } else {
                    return Center(child: Text("No message here yet..."));
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorConstants.themeColor,
                    ),
                  );
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
          border: Border(
              top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)),
          color: Colors.white),
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
                style:
                    TextStyle(color: ColorConstants.primaryColor, fontSize: 15),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText:
                      _startConversation > 180 ? 'Type your message...' : '',
                  hintStyle: TextStyle(color: ColorConstants.greyColor),
                ),
                enabled: _startConversation > 180,
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
                onPressed: _startConversation > 180
                    ? () {
                        sendMessage(textEditingController.text);
                      }
                    : null,
                color: ColorConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String message) {
    if (_startConversation == 300) {
      startConversation();
    }
    // if (_startResponse == defaultResponseTime && _startConversation > 180) {
    // if (_startConversation > 180) {
    //   startResponse(textEditingController.text);
    // }
    setState(() {
      if(message == "end"){
        _startConversation = 190;
      }else{
        _startConversation = 300;
      }
    });
    onSendMessage(message);
  }

  Future<bool> onBackPress() {
    chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      widget.currentUserId,
      {FirestoreConstants.chattingWith: null},
    );
    Navigator.pop(context);

    return Future.value(false);
  }

  Widget buildItem(int index, MessageChat messageChat) {
    if (messageChat.idFrom == widget.currentUserId) {
      // Right (my message)
      return Container(
          margin: EdgeInsets.only(
            bottom: isLastMessageRight(index) ? 20 : 10,
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
      return leftMessage(index, messageChat);
    }
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
                                      color: Colors.white, ),
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
                                      chatProvider
                                          .sendRating(
                                              rating, groupChatId, timeRating)
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
                                  color: Colors.white, ),
                            )
                      )
                ],
              ),
            ]));
  }

  Widget leftMessage(int index, MessageChat messageChat) {
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
                      child: Image.asset(
                        'assets/images/chatbot-data.png',
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(width: 35),
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
                      color: Colors.white, ),
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

  void onSendMessage(String content) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(content, groupChatId, widget.currentUserId, arg);
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: ColorConstants.greyColor);
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) ==
                widget.currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) !=
                widget.currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Timer? _conversationTimer;
  int _startConversation = 300;
  void startConversation() {
    const oneSec = Duration(seconds: 1);
    _conversationTimer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_startConversation == 0) {
          chatProvider.send("Tidak", groupChatId, widget.currentUserId, arg.peerId);
          chatProvider.send(bot.end, groupChatId, arg.peerId, widget.currentUserId);
          chatProvider.send("${bot.close}\n${bot.greet()}", groupChatId, arg.peerId, widget.currentUserId);
          setState(() {
            hasRate = false;
            timeRating = DateTime.now().millisecondsSinceEpoch.toString();
            bot.chatStatus = 0;
            // quests = [];
            timer.cancel();
            _startConversation = 300;
            // historyChat = [];
          });
        }
        if (_startConversation == 180) {
          setState(() {
            _startConversation--;
            chatProvider.send(bot.askAgain, groupChatId, arg.peerId, widget.currentUserId);
          });
        } else {
          setState(() {
            _startConversation--;
          });
        }
      },
    );
  }

  // List<OneChat> historyChat = [];
  // List<String> quests = [];
  // Timer? _responseTimer;
  // int defaultResponseTime = 2;
  // int _startResponse = 2;
  bool isTyping = false;
  void startResponse(String content) {
    // const oneSec = Duration(seconds: 1);
    // _responseTimer = Timer.periodic(
    //   oneSec,
    //   (Timer timer) {
    //     if (_startResponse == 0) {
    // String quest = "";
    // for (var i = 0; i < quest.length; i++) {
    //   quest += "${quests[i]}. ";
    // }
    // historyChat.add(OneChat(content: content, role: "user"));
    // List<OneChat> msm = historyChat;
    // if (msm.length > 10) {
    //   msm =
    //       historyChat.getRange(msm.length - 10, msm.length - 1).toList();
    // }
    // _startResponse--;
    isTyping = true;
    chatProvider
        .getResponse(content, groupChatId, widget.currentUserId, arg, bot)
        .then((res) {
      setState(() {
        bot = res;
        isTyping = false;
        // historyChat = res.hist;
        // quests = [];
        // timer.cancel();
        // _startResponse = defaultResponseTime;
      });
    });
    // } else {
    //   setState(() {
    //     _startResponse--;
    //   });
    // }
    // },
    // );
  }
}

class ScrollListener extends StatefulWidget {
  final Widget Function(BuildContext, ScrollController) builder;
  final VoidCallback loadNext;
  final double threshold;
  final ScrollController controller;
  ScrollListener({
    required this.controller,
    required this.threshold,
    required this.builder,
    required this.loadNext,
  });

  @override
  _ScrollListener createState() => _ScrollListener();
}

class _ScrollListener extends State<ScrollListener> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final rate =
          widget.controller.offset / widget.controller.position.maxScrollExtent;
      if (widget.threshold <= rate) {
        // print(rate);
        widget.loadNext();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.controller);
  }
}
