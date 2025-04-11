import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/context_utils.dart';
import 'package:flutter_app_base/app/global_instances.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:provider/provider.dart';

class SessionManager {
  /// Starts listening to any session-wide providers.
  /// Call this after login, or when resuming a valid session.
  /// TO DO: Add new providers to this method as you add them to the app.
  Future<void> startListeningToProviders({BuildContext? contextOverride}) async {

    // Handle context across async gaps
    final ctx = ContextUtils.getSafeContext(contextOverride);
    if (ctx == null) return;

    logger.i('[INFO - SessionManager] Starting to listen to providers...');

    final usersProvider = Provider.of<UsersProvider>(ctx, listen: false);

    usersProvider.startListening();

    await usersProvider.initializationCompleter.future;
    
    logger.i('[INFO - SessionManager] Providers initialized.');
  }

  /// Stops all provider listeners (called on logout or unexpected disconnect).
  /// TO DO: Add new providers to this method as you add them to the app.
  Future<void> stopListeningToProviders({BuildContext? contextOverride}) async {

    // Handle context across async gaps
    final ctx = ContextUtils.getSafeContext(contextOverride);
    if (ctx == null) return;

    logger.i('[INFO - SessionManager] Stopping all provider listeners...');

    Provider.of<UsersProvider>(ctx, listen: false).stopListening();

    logger.i('[INFO - SessionManager] Providers stopped.');
  }
}
