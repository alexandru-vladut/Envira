import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/app_config.dart';
import 'package:flutter_app_base/app/app_navigator.dart';
import 'package:flutter_app_base/app/global_instances.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/login.dart';
import 'package:flutter_app_base/presentation/widgets/dialog_widgets.dart';

class AuthStateProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  late final StreamSubscription<User?> _authSub;

  bool _manualLogout = false;

  User? get user => _user;
  String? get uid => _user?.uid;
  bool get isLoggedIn => _user != null;

  AuthStateProvider() {
    _authSub = _auth.idTokenChanges().listen((firebaseUser) {
      final wasLoggedIn = _user != null;
      _user = firebaseUser;

      logger.i('[INFO - AuthStateProvider()] Changed → User: ${_user?.uid ?? "null (signed out)"}');

      if (wasLoggedIn && _user == null && !_manualLogout) {
        // Unexpected logout occurred here
        logger.w('[WARNING - AuthStateProvider()] Unexpected logout detected');

        final context = navigatorKey.currentContext;
        if (context != null) {
          logger.i('[INFO - AuthStateProvider()] Showing auto-logout dialog...');
          errorDialog(
            context: context,
            title: "Signed Out",
            text: "You were signed out automatically. Your session may have expired.",
            confirmButtonText: "OK",
            onConfirm: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 200));
              AppNavigator.navigateAndRemoveAllWithKey(navigatorKey, const LoginPage());
            },
          );
        }
      }

      _manualLogout = false; // Reset for next time
      notifyListeners();
    });

    _startTokenRefreshChecker(); // Optional, adds extra reliability
  }

  void _startTokenRefreshChecker() {
    Timer.periodic(const Duration(seconds: AppConfig.authTokenRefreshInterval), (_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.getIdToken(true); // 🔁 Force token refresh
          logger.i('[INFO - _startTokenRefreshChecker()] Token still valid');
        } catch (e) {
          logger.w('[WARNING - _startTokenRefreshChecker()] Token refresh failed, likely disabled/deleted: $e');
          // Firebase will sign out automatically if token is invalid → triggers idTokenChanges(null)
        }
      }
    });
  }

  void markManualLogout() {
    _manualLogout = true;
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}

