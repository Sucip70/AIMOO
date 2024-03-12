import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:minimal/components/chat_stream.dart';
import 'package:minimal/components/components.dart';
import 'package:minimal/constants/constants.dart';
import 'package:minimal/models/bot.dart';
import 'package:minimal/models/chat.dart' as chat;
import 'package:minimal/providers/providers.dart';
import 'package:minimal/widgets/widgets.dart';
import 'package:minimal/models/models.dart';
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

  BotCustom bot = BotCustom();

  // List<QueryDocumentSnapshot> listMessage = [];
  final int _limit = 10;
  String groupChatId = "";

  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";
  double rating = 0;
  String timeRating = "1709914927151";
  bool hasRate = false;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final AuthProvider authProvider = context.read<AuthProvider>();
  Arguments arg = Arguments(
      peerId: OpenAIConstants.id,
      peerAvatar: '',
      peerNickname: 'BOT',
      peerSystem: OpenAIConstants.systemMessage,
      peerEndpoint: OpenAIConstants.endpoint,
      peerIsPublic: false,
      peerKey: '',
      peerTemperature: OpenAIConstants.temperature,
      peerFreqPenalty: OpenAIConstants.freqPenalty,
      peerPresPenalty: OpenAIConstants.presPenalty,
      peerTopP: OpenAIConstants.topP,
      peerMaxTokens: OpenAIConstants.maxTokens,
      peerIsSearchIndex: true,
      peerMode: 'bot',
      peerSearchEndpoint: OpenAIConstants.searchEndpoint,
      peerSearchIndex: OpenAIConstants.searchIndex,
      peerSearchKey: OpenAIConstants.searchKey);
  late Stream<QuerySnapshot> _stream;
  final StreamController<OpenAIStreamChatCompletionModel> _streamChat =
      StreamController();
  String tempResMessage = "";
  String tempReqMessage = "";

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

    groupChatId = "${widget.currentUserId}-${OpenAIConstants.id}";
    _stream = chatProvider.getChatStream(groupChatId, _limit);
    OpenAI.apiKey = "e";
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
              Text(" Contact Us $_startConversation",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ],
          ),
          children: <Widget>[
            SizedBox(
              height: 400,
              child: SafeArea(
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        // Input content
                        StreamChat(
                          currentUserId: widget.currentUserId,
                          groupChatId: groupChatId,
                          stream: _stream,
                          listScrollController: listScrollController,
                          chatProvider: chatProvider,
                          isTyping: isTyping,
                          startConversation: _startConversation,
                          onTimesChanged: onTimesChanged,
                          streamController: _messageController,
                        ),
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
          ],
        ));
  }

  @override
  void dispose() {
    _messageController.close();
    _streamChat.close();
    expandController.dispose();
    if (subs != null) {
      subs.cancel();
    }
    super.dispose();
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const LoadingView() : const SizedBox.shrink(),
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
          Material(
              color: Colors.white,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: PopupMenuButton(
                  enabled: _startConversation > 180 && !isTyping,
                  initialValue: isStream,
                  itemBuilder: ((context) {
                    return buildPopupMenu();
                  }),
                  child: const Icon(
                    Icons.more_vert,
                    color: ColorConstants.primaryColor,
                  ),
                ),
              )),
          // Edit text
          Flexible(
            child: TextField(
              onSubmitted: _startConversation > 180 && !isTyping
                  ? (value) {
                      if (textEditingController.text.isNotEmpty) {
                        startStream(textEditingController.text);
                        // sendMessage(textEditingController.text);
                      }
                    }
                  : null,
              style: const TextStyle(
                  color: ColorConstants.primaryColor, fontSize: 15),
              controller: textEditingController,
              decoration: InputDecoration.collapsed(
                hintText: !isTyping
                    ? _startConversation > 180
                        ? 'Type your message...'
                        : 'Please choose "yes" or "no"!'
                    : 'Click red button to stop!',
                hintStyle: const TextStyle(color: ColorConstants.greyColor),
              ),
              enabled: _startConversation > 180 && !isTyping,
              focusNode: focusNode,
            ),
          ),

          // Button send message
          !isTyping
              ? Material(
                  color: Colors.white,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: IconButton(
                      tooltip: "Send Message",
                      icon: const Icon(Icons.send),
                      onPressed: _startConversation > 180 && !isTyping
                          ? () {
                              if (textEditingController.text.isNotEmpty) {
                                startStream(textEditingController.text);
                                // sendMessage(textEditingController.text);
                              }
                            }
                          : null,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                )
              : Material(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: IconButton(
                      tooltip: "Destroy Stream",
                      icon: const Icon(Icons.stop_circle_outlined,
                          color: Colors.red, size: 25),
                      onPressed: () {
                        if (subs != null) {

                          subs.cancel();
                        }
                        setState(() {
                          _startConversation = 300;
                          isTyping = false;
                        });
                      },
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  bool isStream = true;
  List<PopupChoices> choices = [
    PopupChoices(title: "Stream mode", icon: Icons.toggle_on_rounded),
    PopupChoices(title: "Clear chat", icon: Icons.delete_forever_rounded),
  ];

  List<PopupMenuEntry> buildPopupMenu() {
    return choices
        .map((e) => PopupMenuItem(
          child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Row(
                children: [
                  Expanded(
                    child: Text(e.title,
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  e.title == "Stream mode"
                      ? Transform.scale(
                          scale: 0.6,
                          child: Switch(
                              value: isStream,
                              onChanged: (e) {
                                setState(() {
                                  isStream = e;
                                });
                              }))
                      : IconButton(onPressed: () {
                        chatProvider.clearChat(groupChatId);
                      }, icon: Icon(e.icon, color: Colors.red,))
                ],
              );
            })))
        .toList();
  }

  StreamController<String> _messageController =
      StreamController<String>.broadcast();
  late StreamSubscription<OpenAIStreamChatCompletionModel> subs;

  bool isTyping = false;
  void startStream(String msg) {
    if (_startConversation == 300) {
      startConversation();
    }
    onSendMessage(msg);
    _messageController.add("");
    textEditingController.clear();
    setState(() {
      isTyping = true;
      _startConversation = 300;
      tempReqMessage = msg;
    });
    var sum = "";
    if (_startConversation > 180){
      subs = getAIStream().listen((event) {
        var tmp = event.choices.first.messages.first.delta.content ?? "";
        sum += tmp.replaceAll(RegExp(r'\[doc[0-9]+\]'), '');
        _messageController.add(sum);
      }, onDone: () {
        if (bot.chatStatus == 0) {
          chatProvider.send(bot.greet(), groupChatId, arg.peerId, widget.currentUserId);
          bot.chatStatus = 1;
        }
        if(sum.contains(bot.unwanted)){
          sum = bot.unwantedRes;
        }
        chatProvider.send(sum, groupChatId, arg.peerId, widget.currentUserId);
        isTyping = false;
      }, onError: (e) {
        isTyping = false;
      }, cancelOnError: true);
    }
  }

  Stream<OpenAIStreamChatCompletionModel> getAIStream() {
    return OpenAI.instance.chat
        .createStream(
            url: arg.peerEndpoint,
            model: "gpt-35-turbo",
            messages2: [
              {"role": "system", "content": arg.peerSystem},
              {"role": "user", "content": tempReqMessage},
            ],
            frequencyPenalty: 0.3,
            maxTokens: 300,
            n: 1,
            presencePenalty: 0.6,
            temperature: 0.2,
            topP: 0.9,
            searchEndpoint: arg.peerSearchEndpoint,
            searchIndex: arg.peerSearchIndex,
            searchKey: arg.peerSearchKey)
        .asBroadcastStream();
  }

  // void closeStream() {
  //   _messageController.close();
  // }

  void sendMessage(String message) {
    if (_startConversation == 300) {
      startConversation();
    }
    // if (_startResponse == defaultResponseTime && _startConversation > 180) {
    if (_startConversation > 180) {
      startResponse(textEditingController.text);
    }
    setState(() {
      if (message == "end") {
        _startConversation = 190;
      } else {
        _startConversation = 300;
      }
    });
    onSendMessage(message);
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

  void onTimesChanged(int time) {
    setState(() {
      _startConversation = time;
    });
  }

  // Timer? _conversationTimer;
  int _startConversation = 300;
  void startConversation() {
    const oneSec = Duration(seconds: 1);
    // _conversationTimer =
    Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_startConversation == 0) {
          chatProvider.send(
              "Tidak", groupChatId, widget.currentUserId, arg.peerId);
          chatProvider.send(
              bot.end, groupChatId, arg.peerId, widget.currentUserId);
          chatProvider.send("${bot.close}\n${bot.greet()}", groupChatId,
              arg.peerId, widget.currentUserId);
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
            textEditingController.clear();
            chatProvider.send(
                bot.askAgain, groupChatId, arg.peerId, widget.currentUserId);
          });
        } else {
          setState(() {
            if (!isTyping) {
              _startConversation--;
            }
          });
        }
      },
    );
  }

  void startResponse(String content) {
    isTyping = true;
    chatProvider
        .getResponse(content, groupChatId, widget.currentUserId, arg, bot)
        .then((res) {
      setState(() {
        bot = res;
        isTyping = false;
      });
    });
  }
}

class PopupChoices {
  final String title;
  final IconData icon;

  const PopupChoices({required this.title, required this.icon});
}
