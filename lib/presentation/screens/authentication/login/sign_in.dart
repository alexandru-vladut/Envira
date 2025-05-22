import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/app_navigator.dart';
import 'package:flutter_app_base/app/global_instances.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/sign_up.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/constants.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/validators.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/widgets/my_password_field.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/widgets/my_text_button.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/widgets/my_text_field.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  TextEditingController forgotController = TextEditingController();

  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();

  bool _isPasswordVisible = true;

  @override
  void dispose() {
    focusNodeEmail.dispose();
    focusNodePassword.dispose();
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
        //to make page scrollable
        child: CustomScrollView(
          reverse: true,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome back.", style: kHeadlineLight),
                            SizedBox(height: 10),
                            Text("You've been missed!", style: kBodyText2Light),
                            SizedBox(height: 60),
                            MyTextField(
                              hintText: 'Email',
                              inputType: TextInputType.emailAddress,
                              focusNode: focusNodeEmail,
                              controller: loginEmailController,
                              validator: (value) => isTextValid(value),
                              onFieldSubmitted: (_) {
                                focusNodePassword.requestFocus();
                              },
                              textInputAction: TextInputAction.newline,
                            ),
                            MyPasswordField(
                              isPasswordVisible: _isPasswordVisible,
                              hintText: 'Password',
                              onTap: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              focusNode: focusNodePassword,
                              controller: loginPasswordController,
                              validator: (value) => isTextValid(value),
                              onFieldSubmitted: (_) async {
                                if (_formKey.currentState!.validate()) {
                                  await authService.signIn(email: loginEmailController.text, password: loginPasswordController.text);
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
                          Text("Don't have an account? ", style: kBodyTextLight),
                          GestureDetector(
                            onTap: () {
                              AppNavigator.navigateTo(page: const SignUp(), context: context);
                            },
                            child: Text(
                              'Register',
                              style: kBodyTextLight.copyWith(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      MyTextButton(
                        buttonName: 'Sign In',
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            await authService.signIn(email: loginEmailController.text, password: loginPasswordController.text);
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
