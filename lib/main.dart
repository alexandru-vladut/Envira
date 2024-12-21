import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/providers/user_provider.dart';
import 'package:flutter_app_base/app/firebase_options.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/login.dart';
import 'package:flutter_app_base/presentation/screens/authentication/pin/enter_pin.dart';
import 'package:flutter_app_base/presentation/screens/home.dart';
import 'package:flutter_app_base/app/app_constants.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve the splash screen until loading is complete
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // TO DO: Add Firebase.initializeApp() here
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider(userRepository)),
      ],
      child: const MainApp(),
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    return const MaterialApp(
      title: "Finexa",
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}

class StartChecks extends StatelessWidget {
  const StartChecks({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: returnPageBasedOnLoginStatus(context),
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
}

Future<Widget> returnPageBasedOnLoginStatus(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  
  // If user is logged out, redirect to LoginPage().
  if (user == null) return const LoginPage();

  // If secureLogin is disabled, go to HomePage().
  if (secureLogin == false) {
    // Ensure data required by the home page is loaded here
    authService.startListeningToProviders(context, user.uid);
    return const HomePage();
  }

  // Get user's PIN code
  UserModel currentUser = (await userRepository.getDocumentsByField("uid", user.uid)).first;
  String? currentUserPin = currentUser.pin;

  // If PIN code is not set, force new log-in to set PIN code
  if (currentUserPin == null) {
    authService.logOut(context, showLoadingDialog: false);
    return const LoginPage();
  }

  // If PIN code is set, ask user to enter it
  return const EnterPin();
}
