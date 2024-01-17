import 'package:flutter/material.dart';
import 'package:minimal/components/components.dart';

// TODO Replace with object model.
const String listItemTitleText = "Customer Chat BOT Services";
const String listItemPreviewText =
    "This is the place to test chat bots based on customer services. We use the addition of open AI to get humane and heartfelt answers. The web is built using the Flutter framework";

class ListPage extends StatelessWidget {
  static const String name = 'list';

  const ListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
          children: <Widget>[
            SingleChildScrollView(
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
              child: ChatBox()
            )
          ],
        ),
      );  
  }
}
