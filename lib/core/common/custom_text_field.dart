import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcons;
  final Widget? suffixIcons;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const CustomTextField({super.key, required this.controller, required this.hintText, this.obscureText = false, this.keyboardType, this.prefixIcons, this.suffixIcons, this.focusNode, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      focusNode: focusNode,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcons,
        suffixIcon: suffixIcons,
      ),
    );
  }
}
