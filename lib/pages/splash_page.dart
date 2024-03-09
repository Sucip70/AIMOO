import 'package:flutter/material.dart';
import 'package:minimal/constants/color_constants.dart';
import 'package:minimal/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:session_storage/session_storage.dart';

import 'pages.dart';

class SplashPage extends StatefulWidget {
  static const String name = 'load';

  SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  SessionStorage sessionStorage = SessionStorage();

  @override
  void initState() {
    super.initState();
    checkSignedIn();
  }

  void checkSignedIn() async {
    AuthProvider? authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.isLoggedIn();
    bool flag = sessionStorage['isSigned']?.isNotEmpty ?? false; 

    if (isLoggedIn || flag) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ListPage()),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "images/app_icon.png",
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Container(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: ColorConstants.themeColor),
            ),
          ],
        ),
      ),
    );
  }
}
