import 'package:flutter/material.dart';
import '../../../core/theme/login_theme.dart';

class MyPasswordField extends StatelessWidget {
  const MyPasswordField({
    super.key,
    required this.isPasswordVisible,
    required this.hintText,
    required this.onTap,
    required this.focusNode,
    required this.controller,
    required this.validator,
    required this.onFieldSubmitted,
    required this.textInputAction,
  });

  final bool isPasswordVisible;
  final String? hintText;
  final Function()? onTap;
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
        obscureText: isPasswordVisible,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: onTap,
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Color(0xff616161),
              ),
            ),
          ),
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
