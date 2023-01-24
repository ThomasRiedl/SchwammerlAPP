import 'package:flutter/material.dart';

class CustomTextEditFieldNoVal extends StatelessWidget {
  /// Creates a custom text edit field widget without validation
  ///
  /// [key] is the key for this widget.
  /// [controller] is the text editing controller for the text field
  /// [labettxt] is the label text for the text field
  /// [visibility] is a boolean value to set the text visibility on the text field

  const CustomTextEditFieldNoVal({
    Key? key,
    required this.controller,
    required this.labettxt,
    this.visibility = false,
    this.valid = false,
  }) : super(key: key);
  final TextEditingController controller;
  final String labettxt;
  final bool visibility, valid;

  /// Builds the widget tree for this widget
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 15,
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labettxt,
          labelStyle: const TextStyle(fontSize: 18),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 15),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        controller: controller,
        obscureText: visibility,
      ),
    );
  }
}
