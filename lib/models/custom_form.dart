import 'package:flutter/material.dart';
import 'package:minimal/constants/constants.dart';
import 'package:minimal/widgets/widgets.dart';

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

class ChipPack{
  List<String>? value;
  final FocusNode focusNode = FocusNode();

  ChipPack({required this.value});
}

class ChipCustom extends StatefulWidget{
  const ChipCustom({
    super.key,
    required this.title,
    required this.value,
    required this.isEdit,
    required this.onChanged,
    required this.onSubmitted,
    required this.chipBuilder
  });

  final String title;
  final bool isEdit;
  final List<String> value;

  final ValueChanged<List<String>> onChanged;
  final ValueChanged<String> onSubmitted;

  final Widget Function(BuildContext context, String data, String route) chipBuilder;

  @override
  ChipCustomState createState() => ChipCustomState();
}

class ChipCustomState extends State<ChipCustom>{

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      Container(
        margin: const EdgeInsets.only(left: 20),
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
        child: ChipsInput<String>(
          values: widget.value ?? [],
          strutStyle: const StrutStyle(fontSize: 15),
          onChanged: (value) => widget.onChanged(value),
          onSubmitted: (value) => widget.onSubmitted(value),
          chipBuilder: widget.chipBuilder,
          readOnly: !widget.isEdit,
        ),
      )]);
  }
}

class SliderPack{
  String title;
  String value;
  double min;
  double max;
  final String defaultValue;
  TextEditingController? controller;
  final FocusNode focusNode = FocusNode();
  bool? isInteger = false;
  
  SliderPack({required this.title, 
    required this.value, 
    required this.max, 
    required this.min,
    required this.defaultValue,
    this.isInteger}){
    controller = TextEditingController(text: value);
  }
}

class SliderCustom extends StatefulWidget{
  const SliderCustom({
    super.key,
    required this.title,
    required this.value,
    this.onChangedSlider,
    this.onChangedText,
    required this.isEdit,
    required this.max,
    required this.min,
    this.controller,
    required this.focusNode
  });
  
  final String title;
  final String value;
  final bool isEdit;
  final double max;
  final double min;

  final ValueChanged<double>? onChangedSlider;
  final ValueChanged<String>? onChangedText;

  final TextEditingController? controller;
  final FocusNode focusNode;

  @override
  SliderCustomeState createState() => SliderCustomeState();
}

class SliderCustomeState extends State<SliderCustom>{

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 20, bottom: 5),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 12,
              color: ColorConstants.greyColor
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: <Widget>[
              Flexible(child: 
                Theme(
                  data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                  child: Slider(
                    max: widget.max,
                    min: widget.min,
                    value: double.parse(widget.value),
                    onChanged: widget.isEdit?widget.onChangedSlider:null,
                  )
                ),
              ),
              SizedBox(
                width: 55,
                child: Theme(
                  data: Theme.of(context).copyWith(primaryColor: Colors.red),
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)
                      ),
                      contentPadding: EdgeInsets.all(0)
                    ),
                    keyboardType: TextInputType.number,
                    controller: widget.controller,
                    onChanged: widget.onChangedText,
                    focusNode: widget.focusNode,
                    readOnly: !widget.isEdit,
                  )
                )
              )
            ],
          ),
        )
      ],
    ) ;
  }
}
