import 'package:flutter/material.dart';

class CustomTextEditField extends StatelessWidget {
  /// Creates a custom text edit field widget
  ///
  /// [key] is the key for this widget.
  /// [controller] is the text editing controller for the text field
  /// [labettxt] is the label text for the text field
  /// [visibility] is a boolean value to set the text visibility on the text field
  /// [valid] is a boolean value to set the validation of the text field

  const CustomTextEditField({
    Key? key,
    required this.controller,
    required this.labelttxt,
    this.visibility = false,
    this.valid = false,
  }) : super(key: key);
  final TextEditingController controller;
  final String labelttxt;
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
          labelText: labelttxt,
          labelStyle: const TextStyle(fontSize: 18),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 15),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        controller: controller,
        obscureText: visibility,
        validator: (val) {
          if (val == null || val.isEmpty) {
            return 'Please Fill $labelttxt';
          }
          return null;
        },
      ),
    );
  }
}
