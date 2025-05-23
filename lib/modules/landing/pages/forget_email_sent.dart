import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/app_config.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/modules/authentication/pages/login_page.dart';
import 'package:flutter_app_base/core/theme/theme.dart';

class ForgetEmailSent extends StatelessWidget {

  const ForgetEmailSent({super.key});

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
                    text: '✨ Password Reset Requested ✨\n\n'
                    'A password recovery email has been sent to the email address associated with your account. Please check your inbox for the next steps to reset your password. If you don\'t see the email, be sure to check your spam or junk mail folder, as it can sometimes end up there.\n\n',
                  ),
                  TextSpan(
                    text: '🔗 Follow the Link: ',
                    style: TextStyle(fontWeight: FontWeight.w900,),
                  ),
                  TextSpan(
                    text: 'The email contains a link to reset your password. This link is only valid for a limited time, so please act promptly.\n\n',
                  ),
                  TextSpan(
                    text: '🛡️ Security Notice: ',
                    style: TextStyle(fontWeight: FontWeight.w900,),
                  ),
                  TextSpan(
                    text: 'If you did not request a password reset, please ignore this email. It\'s also a good idea to review your account security settings.\n\n'
                    'Thank you for using ${AppConfig.appName}!',
                  ),
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
                  AppNavigator.navigateAndRemoveAll(page: const LoginPage(), context: context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
