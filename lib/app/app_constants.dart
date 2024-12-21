import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';
import 'package:flutter_app_base/data/services/auth_service.dart';
import 'package:logger/logger.dart';

// INITIALIZE REPOSITORIES AND SERVICES
final UserRepository userRepository = UserRepository();
final AuthService authService = AuthService(userRepository);

/// OTHER CONSTANTS
String appName = 'Finexa';
bool secureLogin = true;
var logger = Logger(printer: PrettyPrinter(),);

/// NAVIGATION
void navigateAndRemoveUntil(context, page) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => page),
    (Route<dynamic> route) => false
  );
}
