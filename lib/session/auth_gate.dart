import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/app_config.dart';
import 'package:flutter_app_base/app/global_instances.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/login.dart';
import 'package:flutter_app_base/presentation/screens/authentication/pin/enter_pin.dart';
import 'package:flutter_app_base/presentation/screens/bottom_nav_bar.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: returnPageBasedOnLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          
          if (!snapshot.hasData) {
            logger.e('[ERROR - StartChecks()] Snapshot has no data.');
            return const Text('[ERROR - StartChecks()] Snapshot has no data.');
          }
          
          FlutterNativeSplash.remove(); // Remove splash screen
          return snapshot.data!; // Return resulted page

        } else {
          // Show a loading spinner while waiting for the future to complete
          // (probably won't be seen because the splash screen is still visible)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Future<Widget> returnPageBasedOnLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    
    // If user is logged out, redirect to LoginPage().
    if (user == null) return const LoginPage();

    // If secureLogin is disabled, go to HomePage().
    if (AppConfig.pinCodeEnabled == false) {
      // Ensure data required by the home page is loaded here
      sessionManager.startListeningToProviders();
      return const BottomNavBar();
    }

    // Get user's PIN code
    UserModel currentUser = (await userRepository.getDocumentsByField("uid", user.uid)).first;
    String? currentUserPin = currentUser.pin;

    // If PIN code is not set, force new log-in to set PIN code
    if (currentUserPin == null) {
      authService.logOut(showLoadingDialog: false);
      return const LoginPage();
    }

    // If PIN code is set, ask user to enter it
    return const EnterPin();
  }
}
