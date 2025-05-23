import 'package:flutter/material.dart';

import '../../../core/theme/login_theme.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.hintText,
    required this.inputType,
    required this.focusNode,
    required this.controller,
    required this.validator,
    required this.onFieldSubmitted,
    required this.textInputAction,
  });
  final String hintText;
  final TextInputType inputType;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        focusNode: focusNode,
        controller: controller,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        textInputAction: textInputAction,
        style: kBodyTextLight.copyWith(color: Colors.black),
        keyboardType: inputType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16),
          hintText: hintText,
          hintStyle: kBodyTextLight,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff616161), width: 1),
            borderRadius: BorderRadius.circular(18),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
