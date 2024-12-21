import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';
import 'package:flutter_app_base/data/services/auth_service.dart';
import 'package:logger/logger.dart';

/// Global logger instance.
var logger = Logger(printer: PrettyPrinter(),);

final UserRepository userRepository = UserRepository();
final AuthService authService = AuthService(userRepository);

/// Enables secure login with email verification and PIN code.
bool secureLogin = true;

String appName = 'Finexa';

void navigateAndRemoveUntil(context, page) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => page),
    (Route<dynamic> route) => false
  );
}
