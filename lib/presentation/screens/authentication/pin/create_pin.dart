// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_app_base/utils/globals.dart';
import 'package:flutter_app_base/utils/theme.dart';

class CreatePin extends StatefulWidget {

  final String email;
  final String password;

  const CreatePin({super.key, required this.email, required this.password});

  @override
  State<CreatePin> createState() => _CreatePinState();
}

class _CreatePinState extends State<CreatePin> {

  String pin = '';
  String confirmPin = '';
  String title = 'Set your PIN code';
  String subtitle = '';
  String inputPin = '';

  void resetProcess() {
    setState(() {
      pin = '';
      confirmPin = '';
      title = 'Set your PIN code';
      inputPin = '';
    });
  }

  /// this widget will be use for each digit
  Widget numButton(int number) {
    return InkWell(
      onTap: () async {

        if (inputPin.length < 4) {
          setState(() {
            inputPin += number.toString();
          });
        }

        if (inputPin.length == 4) {

          if (pin.isEmpty) {

            setState(() {
              pin = inputPin;
              title = 'Re-enter your PIN code';
              subtitle = '';
              inputPin = '';
            });

          } else if (confirmPin.isEmpty) {

            setState(() {
              confirmPin = inputPin;
            });

            if (pin == confirmPin) {
              authService.createPinCode(context, widget.email, widget.password, pin);
            } else {
              subtitle = 'PIN codes don\'t match!';
              resetProcess();
            }
          }
        }
      },

      splashColor: Colors.transparent,
      highlightColor: CustomTheme.darkBlue1.withOpacity(0.2),
      borderRadius: BorderRadius.circular(40),
      
      child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomTheme.darkBlue1.withOpacity(0.05),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 40),
          physics: const BouncingScrollPhysics(),
          children: [

            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  // fontWeight: FontWeight.w500,
                  fontFamily: "DMSans"
                ),
              ),
            ),

            const SizedBox(height: 60),

            Center(
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  // fontWeight: FontWeight.w600,
                  fontFamily: "DMSans",
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// pin code area
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) {
                  return Container(
                    margin: const EdgeInsets.all(10.0),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: index < inputPin.length
                          ? CustomTheme.darkBlue1
                          : CustomTheme.darkBlue1.withOpacity(0.1),
                    ),
                    child: null,
                  );
                },
              ),
            ),

            const SizedBox(height: 80),

            /// digits
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3,
                    (index) => numButton(1 + 3 * i + index),
                  ).toList(),
                ),
              ),

            /// 0 digit with back remove
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (pin.isEmpty)
                  ? const InkWell(onTap: null, child: SizedBox(width: 80, height: 80,))
                  : InkWell(
                      onTap: () {
                        resetProcess();
                      },

                      splashColor: Colors.transparent,
                      highlightColor: CustomTheme.darkBlue1.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),

                      child: const SizedBox(
                        width: 80,
                        height: 80,
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                          size: 35,
                        ),
                      ),
                  ),
                  numButton(0),
                  InkWell(
                    onTap: () {
                      setState(
                        () {
                          if (inputPin.isNotEmpty) {
                            inputPin = inputPin.substring(0, inputPin.length - 1);
                          }
                        },
                      );
                    },

                    splashColor: Colors.transparent,
                    highlightColor: CustomTheme.darkBlue1.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),

                    child: const SizedBox(
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.backspace,
                        color: Colors.black,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
