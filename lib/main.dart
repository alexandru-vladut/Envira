import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/data/providers/companies_provider.dart';
import 'package:flutter_app_base/data/providers/products_provider.dart';
import 'package:flutter_app_base/data/providers/transactions_provider.dart';
import 'package:flutter_app_base/data/providers/vouchers_provider.dart';
import 'package:flutter_app_base/modules/recycle/services/gemini_service.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:flutter_app_base/session/connection_gate.dart';
import 'package:flutter_app_base/session/connection_state_provider.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve the splash screen until loading is complete
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize AI Service
  GeminiService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectionStateProvider>(
          create: (_) => ConnectionStateProvider(),
        ),
        ChangeNotifierProvider<AuthStateProvider>(
          create: (_) => AuthStateProvider(),
        ),
        // TO DO: Add new providers here
        ChangeNotifierProvider<UsersProvider>(
          create: (_) => UsersProvider(userRepository),
        ),
        ChangeNotifierProvider<VouchersProvider>(
          create: (_) => VouchersProvider(voucherRepository),
        ),
        ChangeNotifierProvider<TransactionsProvider>(
          create: (_) => TransactionsProvider(transactionRepository),
        ),
        ChangeNotifierProvider<CompaniesProvider>(
          create: (_) => CompaniesProvider(companyRepository),
        ),
        ChangeNotifierProvider<ProductsProvider>(
          create: (_) => ProductsProvider(productRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      title: "App Base",
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // 👈 Plug in your global navigator key here
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: CustomTheme.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ConnectionGate(),
    );
  }
}
