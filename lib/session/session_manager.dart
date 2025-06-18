import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/utils/context_utils.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/data/providers/companies_provider.dart';
import 'package:flutter_app_base/data/providers/news_provider.dart';
import 'package:flutter_app_base/data/providers/products_provider.dart';
import 'package:flutter_app_base/data/providers/transactions_provider.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/data/providers/vouchers_provider.dart';
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
    final vouchersProvider = Provider.of<VouchersProvider>(ctx, listen: false);
    final transactionsProvider = Provider.of<TransactionsProvider>(ctx, listen: false);
    final companiesProvider = Provider.of<CompaniesProvider>(ctx, listen: false);
    final productsProvider = Provider.of<ProductsProvider>(ctx, listen: false);
    final newsProvider = Provider.of<NewsProvider>(ctx, listen: false);

    usersProvider.startListening();
    vouchersProvider.startListening();
    transactionsProvider.startListening();
    companiesProvider.startListening();
    productsProvider.startListening();
    newsProvider.startListening();

    await usersProvider.initializationCompleter.future;
    await vouchersProvider.initializationCompleter.future;
    await transactionsProvider.initializationCompleter.future;
    await companiesProvider.initializationCompleter.future;
    await productsProvider.initializationCompleter.future;
    await newsProvider.initializationCompleter.future;
    
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
    Provider.of<VouchersProvider>(ctx, listen: false).stopListening();
    Provider.of<TransactionsProvider>(ctx, listen: false).stopListening();
    Provider.of<CompaniesProvider>(ctx, listen: false).stopListening();
    Provider.of<ProductsProvider>(ctx, listen: false).stopListening();
    Provider.of<NewsProvider>(ctx, listen: false).stopListening();

    logger.i('[INFO - SessionManager] Providers stopped.');
  }
}
