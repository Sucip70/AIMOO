
import 'package:flutter/material.dart';

class ScrollListener extends StatefulWidget {
  final Widget Function(BuildContext, ScrollController) builder;
  final VoidCallback loadNext;
  final double threshold;
  final ScrollController controller;
  
  const ScrollListener({
    super.key,
    required this.controller,
    required this.threshold,
    required this.builder,
    required this.loadNext,
  });

  @override
  // ignore: library_private_types_in_public_api
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
