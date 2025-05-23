import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/repositories/company_repository.dart';
import 'package:flutter_app_base/data/repositories/transaction_repository.dart';
import 'package:flutter_app_base/data/repositories/voucher_repository.dart';
import 'package:flutter_app_base/session/session_manager.dart';
import 'package:logger/logger.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';
import 'package:flutter_app_base/data/services/auth_service.dart';

/// 🔐 Repositories
final UserRepository userRepository = UserRepository();
final VoucherRepository voucherRepository = VoucherRepository();
final TransactionRepository transactionRepository = TransactionRepository();
final CompanyRepository companyRepository = CompanyRepository();

/// 🛠 Services
final AuthService authService = AuthService(userRepository);
final SessionManager sessionManager = SessionManager();

/// 📋 Logger
final Logger logger = Logger(printer: PrettyPrinter());

/// 🧭 Navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
