import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_app_base/app/global_instances.dart';
import 'package:flutter_app_base/presentation/screens/authentication/landing_pages/no_internet_page.dart';

class ConnectionStateProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isConnected => _isConnected;

  ConnectionStateProvider() {
    _startListening();
  }

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final wasConnected = _isConnected;
      _isConnected = await _checkConnection(results);

      if (wasConnected && !_isConnected) {
        notifyListeners();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
          (_) => false,
        );
      }
    });
  }

  Future<void> recheckConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = await _checkConnection(result);
    notifyListeners();
  }

  Future<bool> _checkConnection(List<ConnectivityResult> results) async {
    return !results.contains(ConnectivityResult.none);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
