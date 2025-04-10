import 'package:flutter/material.dart';
import 'package:flutter_app_base/session/session_manager.dart';
import 'package:logger/logger.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';
import 'package:flutter_app_base/data/services/auth_service.dart';

/// 🔐 Repositories
final UserRepository userRepository = UserRepository();

/// 🛠 Services
final AuthService authService = AuthService(userRepository);
final SessionManager sessionManager = SessionManager();

/// 📋 Logger
final Logger logger = Logger(printer: PrettyPrinter());

/// 🧭 Navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
