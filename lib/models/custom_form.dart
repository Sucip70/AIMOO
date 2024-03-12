import 'package:flutter/material.dart';
import 'package:minimal/constants/constants.dart';

class TextFieldPack{
  String title;
  String value;
  String hint;
  TextEditingController? controller;
  final FocusNode focusNode = FocusNode();

  TextFieldPack({
    required this.title,
    required this.value,
    required this.hint
  }){
    controller = TextEditingController(text: value);
  }
}

class TextFieldCustom extends StatefulWidget{
  const TextFieldCustom({super.key, 
    required this.title,
    required this.hint,
    required this.value,
    this.onChanged,
    this.controller,
    required this.focusNode,
    required this.isEdit,
    required this.validate
  });

  final String title;
  final String hint;
  final String value;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode focusNode;
  final bool isEdit;
  final bool validate;

  @override
  TextFieldCustomState createState() => TextFieldCustomState();
}

class TextFieldCustomState extends State<TextFieldCustom>{
  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, bottom: 0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 12,
              color: ColorConstants.greyColor
              ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
            child: TextField(
              decoration: InputDecoration(
                hintText: widget.hint,
                contentPadding: const EdgeInsets.all(5),
                hintStyle: const TextStyle(color: ColorConstants.greyColor),
                errorText: widget.validate ? "Value can't be empty": null
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
