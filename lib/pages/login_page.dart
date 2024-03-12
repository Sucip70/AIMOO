import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:minimal/components/blog.dart';
import 'package:minimal/constants/color_constants.dart';
import 'package:minimal/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:animated_background/animated_background.dart';
import 'package:session_storage/session_storage.dart';

import '../widgets/widgets.dart';
import 'pages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  TextFieldPack username = TextFieldPack(hint: "Username", value: "");
  TextFieldPack password = TextFieldPack(hint: "Password", value: "");
  SessionStorage session = SessionStorage();

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign in fail");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign in canceled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign in success");
        break;
      default:
        break;
    }
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              // color: Color.fromARGB(255, 25, 14, 62),
              gradient: RadialGradient(colors: [
                // Color.fromARGB(255, 34, 18, 87),
                const Color.fromARGB(255, 0, 255, 217).withOpacity(0.9),
                const Color.fromARGB(255, 25, 14, 62),
                const Color.fromARGB(255, 0, 255, 217).withOpacity(0.9),
              ], center: Alignment.topRight, radius: 2.5),
            ),
            child: AnimatedBackground(
                behaviour: RacingLinesBehaviour(
                  direction: LineDirection.Ltr,
                  numLines: 50,
                ),
                vsync: this,
                child: Container(
                    color: Colors.black54,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: const AppTitle(
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                        Center(
                          child: ClipRect(
                              child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 10.0, sigmaY: 10.0),
                                  child: Container(
                                      constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.6,
                                          maxWidth: 400),
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                            colors: [
                                              const Color.fromARGB(255, 0, 255, 217)
                                                  .withOpacity(0.9),
                                              const Color.fromARGB(255, 0, 255, 217)
                                                  .withOpacity(0.1)
                                            ],
                                            center: Alignment.topCenter,
                                            radius: 1.1),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            margin: const EdgeInsetsDirectional
                                                .only(top: 20, bottom: 20),
                                            child: const Text("CUSTOMER LOGIN",
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color.fromARGB(
                                                        255, 25, 14, 62))),
                                          ),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: TextFieldCustom(
                                                focusNode: username.focusNode,
                                                controller: username.controller,
                                                hint: username.hint,
                                                isEdit: true,
                                                validate: false,
                                                value: username.value,
                                                icon: const Icon(
                                                    Icons.account_circle),
                                              )),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: TextFieldCustom(
                                                focusNode: password.focusNode,
                                                controller: password.controller,
                                                hint: password.hint,
                                                isEdit: true,
                                                validate: false,
                                                value: password.value,
                                                icon: const Icon(Icons.key),
                                              )),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 50,
                                                right: 50,
                                                top: 10,
                                                bottom: 30),
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              style: const ButtonStyle(
                                                  splashFactory:
                                                      NoSplash.splashFactory,
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Color.fromARGB(255,
                                                              181, 255, 244))),
                                              child: const Text(
                                                "Login",
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        166, 13, 106, 92)),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 40,
                                                right: 40,
                                                bottom: 20),
                                            child: const Divider(
                                                color: Color.fromARGB(
                                                    255, 25, 14, 62)),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              authProvider
                                                  .handleSignIn()
                                                  .then((isSuccess) {
                                                session['isSigned'] =
                                                    isSuccess.toString();
                                                if (isSuccess) {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ListPage(),
                                                    ),
                                                  );
                                                }
                                              }).catchError(
                                                      (error, stackTrace) {
                                                Fluttertoast.showToast(
                                                    msg: error.toString());
                                                authProvider.handleException();
                                              });
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                                  if (states.contains(
                                                      MaterialState.pressed)){
                                                    return const Color.fromARGB(
                                                            255, 221, 57, 79)
                                                        .withOpacity(0.8);
                                                    }
                                                  return const Color.fromARGB(
                                                      255, 221, 57, 79);
                                                },
                                              ),
                                              shadowColor:const 
                                                  MaterialStatePropertyAll(
                                                      Colors.black),
                                              splashFactory:
                                                  NoSplash.splashFactory,
                                              padding: MaterialStateProperty
                                                  .all<EdgeInsets>(
                                                const EdgeInsets.fromLTRB(
                                                    30, 15, 30, 15),
                                              ),
                                            ),
                                            child: const Text(
                                              'Sign in with Google',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      )))),
                        ),
                        // Loading
                        Positioned(
                          child: authProvider.status == Status.authenticating
                              ? const LoadingView()
                              : const SizedBox.shrink(),
                        ),
                      ],
                    )))));
  }
}

class TextFieldPack {
  String value;
  String hint;
  TextEditingController? controller;
  final FocusNode focusNode = FocusNode();

  TextFieldPack({required this.value, required this.hint}) {
    controller = TextEditingController(text: value);
  }
}

class TextFieldCustom extends StatefulWidget {
  const TextFieldCustom(
      {super.key,
      required this.hint,
      required this.value,
      this.onChanged,
      this.controller,
      required this.focusNode,
      required this.isEdit,
      required this.validate,
      required this.icon});

  final String hint;
  final String value;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode focusNode;
  final bool isEdit;
  final bool validate;
  final Icon icon;

  @override
  TextFieldCustomState createState() => TextFieldCustomState();
}

class TextFieldCustomState extends State<TextFieldCustom> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: Theme(
            data: Theme.of(context)
                .copyWith(primaryColor: ColorConstants.primaryColor),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: widget.icon,
                hintText: widget.hint,
                border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 0, 255, 217), width: 0),
                    borderRadius: BorderRadius.circular(30)),
                contentPadding: const EdgeInsets.all(5),
                hintStyle: const TextStyle(color: ColorConstants.greyColor),
                errorText: widget.validate ? "Value can't be empty" : null,
                fillColor: const Color.fromARGB(255, 0, 23, 69),
                filled: true,
                prefixIconColor: const Color.fromARGB(255, 0, 255, 217),
                focusColor: const Color.fromARGB(255, 0, 255, 217),
              ),
              controller: widget.controller,
              onChanged: widget.onChanged,
              focusNode: widget.focusNode,
              readOnly: !widget.isEdit,
            ),
          ),
        ),
      ],
    );
  }
}
