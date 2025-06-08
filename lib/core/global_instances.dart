import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/repositories/company_repository.dart';
import 'package:flutter_app_base/data/repositories/product_repository.dart';
import 'package:flutter_app_base/data/repositories/recycle_point_repository.dart';
import 'package:flutter_app_base/data/repositories/transaction_repository.dart';
import 'package:flutter_app_base/data/repositories/voucher_repository.dart';
import 'package:flutter_app_base/modules/recycle/services/product_service.dart';
import 'package:flutter_app_base/modules/recycle/services/recycle_service.dart';
import 'package:flutter_app_base/modules/work_log/services/work_log_service.dart';
import 'package:flutter_app_base/modules/vouchers/services/voucher_service.dart';
import 'package:flutter_app_base/session/session_manager.dart';
import 'package:logger/logger.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';
import 'package:flutter_app_base/modules/authentication/services/auth_service.dart';

/// 🔐 Repositories
final UserRepository userRepository = UserRepository();
final VoucherRepository voucherRepository = VoucherRepository();
final TransactionRepository transactionRepository = TransactionRepository();
final CompanyRepository companyRepository = CompanyRepository();
final ProductRepository productRepository = ProductRepository();
final RecyclePointRepository recyclePointRepository = RecyclePointRepository();

/// 🛠 Services
final SessionManager sessionManager = SessionManager();
final AuthService authService = AuthService(userRepository);
final RecycleService recycleService = RecycleService(userRepository, transactionRepository);
final ProductService productService = ProductService(productRepository);
final VoucherService voucherService = VoucherService(userRepository);
final WorkLogService workLogService = WorkLogService(userRepository, transactionRepository);

/// 📋 Logger
final Logger logger = Logger(printer: PrettyPrinter());

/// 🧭 Navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
