import 'package:flutter/material.dart';
import 'package:flutter_app_base/session/auth_gate.dart';
import 'package:flutter_app_base/session/connection_state_provider.dart';
import 'package:flutter_app_base/modules/landing/pages/no_internet_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

class ConnectionGate extends StatelessWidget {
  const ConnectionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkInitialConnection(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!) {
          FlutterNativeSplash.remove(); // Remove splash screen
          return const NoInternetPage(); // 👈 offline at launch
        }

        return const AuthGate(); // 👈 connected → normal flow
      },
    );
  }

  Future<bool> _checkInitialConnection(BuildContext context) async {
    final provider = Provider.of<ConnectionStateProvider>(context, listen: false);
    await provider.recheckConnection();
    return provider.isConnected;
  }
}