import 'package:flutter/material.dart';

class MyTextformfield extends StatelessWidget {
  const MyTextformfield({
    super.key,
    required this.hintText,
    required this.controller,
    required this.labelText,
    this.errorMessage, 
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final String? errorMessage;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText, 
        hintText: hintText,
        suffixIcon: suffixIcon
      ),

      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return errorMessage;
        }
        return null;
      },
    );
  }
}