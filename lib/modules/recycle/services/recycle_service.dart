import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/dialog_widgets.dart';
import 'package:flutter_app_base/data/models/transaction_model.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/data/repositories/transaction_repository.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';
import 'package:flutter_app_base/modules/bottom_nav_bar.dart';
import 'package:flutter_app_base/modules/recycle/pages/barcode_scanner_page.dart';
import 'package:flutter_app_base/modules/recycle/pages/scan_product_result.dart';
import 'package:flutter_app_base/modules/recycle/products.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:provider/provider.dart';

class RecycleService {
  // Inject repositories
  final UserRepository _userRepository;
  final TransactionRepository _transactionRepository;

  // Regular constructor
  RecycleService(
    this._userRepository,
    this._transactionRepository,
  );

  Future<void> scanBarcode(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerPage(
          onBarcodeDetected: (String barcode) {
            Navigator.of(context).pop(barcode);
          },
        ),
      ),
    );

    if (result != null) {
      String barcodeScanRes = result;
      
      if (products.keys.contains(barcodeScanRes)) {
        AppNavigator.navigateTo(page: ScanProductResultPage(barcode: barcodeScanRes));
      } else {
        scanBarcode(context);
      }
    }
  }

  Future<void> recycleProduct(BuildContext context, String barcode) async {
    
    loadingDialog(context: context);

    try {
      // Get current user UID from auth provider
      final currentUserUid = context.read<AuthStateProvider>().uid;
      if (currentUserUid == null) {
        AppNavigator.pop(); // Close loading dialog
        errorDialog(
          context: context,
          title: 'User not authenticated'
        );
        return;
      }

      // Get current user data from users provider
      final currentUser = context.read<UsersProvider>().items
          .firstWhereOrNull((u) => u.uid == currentUserUid);
      
      if (currentUser == null) {
        AppNavigator.pop(); // Close loading dialog
        errorDialog(
          context: context,
          title: 'User data not found'
        );
        return;
      }

      // Get product data
      final product = products[barcode];
      if (product == null) {
        AppNavigator.pop(); // Close loading dialog
        errorDialog(
          context: context,
          title: 'Product not found'
        );
        return;
      }

      final newPoints = product['points'] as int;
      final updatedTotalPoints = currentUser.totalPoints + newPoints;
      final updatedCredits = currentUser.credits + newPoints;

      // Update user's total points
      await _userRepository.updateDocumentField(
        currentUser.docId!,
        'totalPoints',
        updatedTotalPoints,
      );

      // Update user's credits
      await _userRepository.updateDocumentField(
        currentUser.docId!,
        'credits',
        updatedCredits,
      );

      // Create and add transaction
      final transaction = TransactionModel(
        value: newPoints,
        userUid: currentUserUid,
        timestamp: DateTime.now(),
      );

      await _transactionRepository.addDocument(transaction);

      // Success - navigate to home
      AppNavigator.pop(); // Close loading dialog
      AppNavigator.navigateTo(page: BottomNavBar());

    } catch (error) {
      AppNavigator.pop(); // Close loading dialog
      errorDialog(
        context: context,
        title: 'Error processing recycle: $error'
      );
    }
  }
}