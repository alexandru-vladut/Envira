import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/app_navigator.dart';
import 'package:flutter_app_base/session/auth_gate.dart';
import 'package:flutter_app_base/session/connection_state_provider.dart';
import 'package:flutter_app_base/presentation/widgets/dialog_widgets.dart';
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
                onPressed: () => _handleRetryPressed(context),
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRetryPressed(BuildContext context) async {
    loadingDialog(context);

    await context.read<ConnectionStateProvider>().recheckConnection();
    final isConnected = context.read<ConnectionStateProvider>().isConnected;

    if (isConnected) {
      await Future.delayed(const Duration(milliseconds: 200));
      Navigator.pop(context); // Dismiss loading
      await Future.delayed(const Duration(milliseconds: 200));
      AppNavigator.navigateAndRemoveAll(context, const AuthGate());
    } else {
      Navigator.pop(context); // Dismiss loading
      errorDialog(
        context: context,
        title: "Still No Internet Connection",
      );
    }
  }
}
