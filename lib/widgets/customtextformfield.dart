
// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
class customTextFormfield extends StatelessWidget {
  final TextEditingController questionController;
  final String labelText;
  const customTextFormfield({
    super.key,
    required this.questionController,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText, 
        labelStyle: TextStyle(color: Colors.teal),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.blueGrey, width: 2.0),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.teal, width: 2.0),
        ),
      ),
      controller: questionController,
    );
  }
}
