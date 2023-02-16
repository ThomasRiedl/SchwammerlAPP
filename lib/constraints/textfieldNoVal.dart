import 'package:flutter/material.dart';

class CustomTextEditFieldNoVal extends StatelessWidget {
  const CustomTextEditFieldNoVal({
    Key? key,
    required this.controller,
    required this.labelttxt,
    this.visibility = false,
    this.valid = false,
  }) : super(key: key);
  final TextEditingController controller;
  final String labelttxt;
  final bool visibility, valid;
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
      ),
    );
  }
}
