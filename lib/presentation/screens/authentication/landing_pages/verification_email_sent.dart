import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/app_config.dart';
import 'package:flutter_app_base/app/app_navigator.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/login.dart';
import 'package:flutter_app_base/app/theme.dart';

class VerificationEmailSent extends StatelessWidget {

  const VerificationEmailSent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.darkBlue1,
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Image(
              height: 100,
              image: AssetImage('assets/images/info.png')
            ),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'DMSans'
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '🎉 Welcome to ${AppConfig.appName}! 🚀\n\n'
                    'Thank you for signing up! We\'re excited to have you on board. To get started, there\'s just one small step left:\n\n',
                  ),
                  TextSpan(
                    text: '📧 Check Your Inbox: ',
                    style: TextStyle(fontWeight: FontWeight.w900,),
                  ),
                  TextSpan(
                    text: 'We\'ve sent a verification email to the address you provided. Please click on the link in that email to verify your account. Can\'t find it? Remember to check your spam folder just in case!\n\n'
                    'Once verified, you\'ll have full access to all the amazing features ${AppConfig.appName} has to offer. Happy exploring!\n\n'
                    '🌟 ${AppConfig.appName} Team 🌟',
                  )
                ]
              ),
            ),

            Container(
              width: 230.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                color: const Color.fromARGB(255, 0, 10, 75),
                border: Border.all(
                  color: Colors.white,
                  width: 1.0,
                ),
              ),
              child: MaterialButton(
                highlightColor: Colors.transparent,
                splashColor: const Color.fromARGB(255, 38, 40, 110),
                child: const Text(
                  'Go to Login',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontFamily: 'WorkSansBold'),
                ),
                onPressed: () {
                  AppNavigator.navigateAndRemoveAll(context, const LoginPage());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
