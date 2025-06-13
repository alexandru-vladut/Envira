import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/home_theme.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/modules/authentication/pages/signin_page.dart';
import 'package:flutter_app_base/modules/authentication/pages/signup_page.dart';
import 'package:flutter_app_base/core/theme/login_theme.dart';
import 'package:flutter_app_base/modules/authentication/widgets/my_text_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeAppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: [
              Flexible(
                child: Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Image(
                          image: AssetImage(
                            'assets/images/team_illustration.png',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Enterprise team\ncollaboration.",
                      style: kHeadlineLight,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      // width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        "Bring together your files, your tools, project and people. Including a new mobile and desktop application.",
                        style: kBodyTextLight,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: MyTextButton(
                        bgColor: Colors.transparent,
                        buttonName: 'Register',
                        onTap: () {
                          AppNavigator.navigateTo(page: const SignUp(), context: context, withCupertino: true);
                        },
                        textColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: MyTextButton(
                        bgColor: Colors.white,
                        buttonName: 'Sign In',
                        onTap: () {
                          AppNavigator.navigateTo(page: const SignIn(), context: context, withCupertino: true);
                        },
                        textColor: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
