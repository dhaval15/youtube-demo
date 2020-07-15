import 'dart:async';

import 'package:flutter/material.dart';

class DebounceTextField extends StatefulWidget {
  final Function(String text) onChanged;
  final InputDecoration decoration;

  const DebounceTextField({
    Key key,
    this.onChanged,
    this.decoration,
  }) : super(key: key);
  @override
  _DebounceTextFieldState createState() => _DebounceTextFieldState();
}

class _DebounceTextFieldState extends State<DebounceTextField> {
  final TextEditingController controller = TextEditingController();
  Timer debounce;

  @override
  void initState() {
    super.initState();
    controller.addListener(onChanged);
  }

  void onChanged() {
    if (debounce?.isActive ?? false) debounce.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onChanged(controller.text);
    });
  }

  @override
  void dispose() {
    controller.removeListener(onChanged);
    controller.dispose();
    debounce.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: widget.decoration,
    );
  }
}
