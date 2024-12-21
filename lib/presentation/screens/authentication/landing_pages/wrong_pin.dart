import 'package:flutter/material.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/login.dart';
import 'package:flutter_app_base/utils/globals.dart';
import 'package:flutter_app_base/utils/theme.dart';

class WrongPin extends StatelessWidget {

  const WrongPin({super.key});

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
              image: AssetImage('assets/images/x.png')
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
                    text: '🚫 Access Blocked 🚫\n\n'
                    'Oops! It looks like the PIN entered was incorrect multiple times. As a security measure, we have signed you out of your account. This is to ensure the safety and confidentiality of your account information.\n\n',
                  ),
                  TextSpan(
                    text: '🔐 Forgot Your PIN? ',
                    style: TextStyle(fontWeight: FontWeight.w900,),
                  ),
                  TextSpan(
                    text: 'Don\'t worry, it happens! If you have forgotten your PIN, please contact the bank directly for assistance with resetting it. Our team is here to help you regain access securely.\n\n'
                    'We appreciate your understanding and cooperation in keeping your account secure!',
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
                  navigateAndRemoveUntil(context, const LoginPage());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
