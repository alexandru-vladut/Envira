import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/core/utils/context_utils.dart';
import 'package:flutter_app_base/session/auth_gate.dart';
import 'package:flutter_app_base/session/connection_state_provider.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/dialog_widgets.dart';
import 'package:provider/provider.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text("No Internet Connection", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _handleRetryPressed(),
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRetryPressed() async {

    loadingDialog();

    // Handle context across async gaps
    final ctx = ContextUtils.getSafeContext();
    if (ctx == null) return;

    final connectionProvider = ctx.read<ConnectionStateProvider>();
    await connectionProvider.recheckConnection();
    final isConnected = connectionProvider.isConnected;

    if (isConnected) {
      await Future.delayed(const Duration(milliseconds: 200));
      AppNavigator.pop(); // Dismiss loading
      await Future.delayed(const Duration(milliseconds: 200));
      AppNavigator.navigateAndRemoveAll(page: const AuthGate());
    } else {
      AppNavigator.pop(); // Dismiss loading
      errorDialog(title: "Still No Internet Connection");
    }
  }
}
