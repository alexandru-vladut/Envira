import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/app_navigator.dart';
import 'package:flutter_app_base/app/global_instances.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/sign_in.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/validators.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/widgets/my_password_field.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/widgets/my_text_button.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/widgets/my_text_field.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/constants.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {

  final _formKey = GlobalKey<FormState>();

  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColorLight,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image(
            width: 24,
            color: Colors.black,
            image: Svg('assets/images/back_arrow.svg'),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Register", style: kHeadlineLight),
                            Text(
                              "Create new account to get started.",
                              style: kBodyText2Light,
                            ),
                            SizedBox(height: 42),
                            MyTextField(
                              hintText: 'Name',
                              inputType: TextInputType.name,
                              focusNode: nameFocusNode,
                              controller: nameController,
                              validator: (value) => isTextValid(value),
                              onFieldSubmitted: (_) {
                                emailFocusNode.requestFocus();
                              },
                              textInputAction: TextInputAction.newline,
                            ),
                            MyTextField(
                              hintText: 'Email',
                              inputType: TextInputType.emailAddress,
                              focusNode: emailFocusNode,
                              controller: emailController,
                              validator: (value) => isEmailValid(value),
                              onFieldSubmitted: (_) {
                                passwordFocusNode.requestFocus();
                              },
                              textInputAction: TextInputAction.newline,
                            ),
                            MyPasswordField(
                              isPasswordVisible: _obscureTextPassword,
                              hintText: 'Password',
                              onTap: () {
                                setState(() {
                                  _obscureTextPassword = !_obscureTextPassword;
                                });
                              },
                              focusNode: passwordFocusNode,
                              controller: passwordController,
                              validator: (value) => isPasswordValid(value),
                              onFieldSubmitted: (_) {
                                confirmPasswordFocusNode.requestFocus();
                              },
                              textInputAction: TextInputAction.newline,
                            ),
                            MyPasswordField(
                              isPasswordVisible: _obscureTextConfirmPassword,
                              hintText: 'Confirm Password',
                              onTap: () {
                                setState(() {
                                  _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
                                });
                              },
                              focusNode: confirmPasswordFocusNode,
                              controller: confirmPasswordController,
                              validator: (value) => isConfirmPasswordValid(passwordController.text, value),
                              onFieldSubmitted: (_) {
                                if (_formKey.currentState!.validate()) {
                                  authService.signUp(emailController.text, nameController.text, passwordController.text, confirmPasswordController.text);
                                }
                              },
                              textInputAction: TextInputAction.go,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account? ", style: kBodyTextLight),
                          GestureDetector(
                            onTap: () {
                              AppNavigator.navigateTo(page: const SignIn(), context: context);
                            },
                            child: Text(
                              "Sign In",
                              style: kBodyText.copyWith(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      MyTextButton(
                        buttonName: 'Register',
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            authService.signUp(emailController.text, nameController.text, passwordController.text, confirmPasswordController.text);
                          }
                        },
                        bgColor: kBackgroundColor,
                        textColor: Colors.white,
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
