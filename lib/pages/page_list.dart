import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minimal/components/components.dart';
import 'package:minimal/pages/login_page.dart';
import 'package:minimal/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// TODO Replace with object model.
const String listItemTitleText = "Customer Chat BOT Services";
const String listItemPreviewText =
    "This is the place to test chat bots based on customer services. We use the addition of open AI to get humane and heartfelt answers. The web is built using the Flutter framework";

class ListPage extends StatefulWidget {
  static const String name = 'list';
  const ListPage({Key? key});

  ListPageState createState()=> ListPageState();
}

class ListPageState extends State<ListPage> {
  ListPageState({Key? key});

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  late final AuthProvider authProvider = context.read<AuthProvider>();
  late final String currentUserId;

  @override
  void initState() {
    super.initState();
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: <Widget>[
            const SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  MinimalMenuBar(),
                  ListItem(
                      imageUrl:
                          "assets/images/5124556.jpg",
                      title: listItemTitleText,
                      description: listItemPreviewText),
                  divider,
                 Footer(),
                ],
              ),
              // ),
            ),
            Positioned(
              bottom: 0.0,
              right: 20.0,
              child: ChatBox(currentUserId: currentUserId,)
            )
          ],
        ),
      );  
  }
}
