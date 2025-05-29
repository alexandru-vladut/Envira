import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets.dart';
import 'package:flutter_app_base/data/models/transaction_model.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/modules/bottom_nav_bar.dart';
import 'package:flutter_app_base/modules/recycle_action/pages/barcode_scanner_page.dart';
import 'package:flutter_app_base/modules/recycle_action/pages/scan_product_result.dart';
import 'package:flutter_app_base/modules/recycle_action/products.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:provider/provider.dart';

class RecycleService {
  static Future<void> scanBarcode(BuildContext context) async {
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
      
      if (barcodeScanRes == '59489184' || barcodeScanRes == '59492573') {
        AppNavigator.navigateTo(page: ScanProductResultPage(barcode: barcodeScanRes));
      } else {
        scanBarcode(context);
      }
    }
  }

  static Future<void> recycleProduct(BuildContext context, String barcode) async {
    try {
      // Get current user UID from auth provider
      final currentUserUid = context.read<AuthStateProvider>().uid;
      if (currentUserUid == null) {
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
        errorDialog(
          context: context,
          title: 'User data not found'
        );
        return;
      }

      // Get product data
      final product = products[barcode];
      if (product == null) {
        errorDialog(
          context: context,
          title: 'Product not found'
        );
        return;
      }

      final newPoints = product['points'] as int;
      final updatedTotalPoints = currentUser.totalPoints + newPoints;

      // Update user's total points
      await userRepository.updateDocumentField(
        currentUser.docId!,
        'totalPoints',
        updatedTotalPoints,
      );

      // Create and add transaction
      final transaction = TransactionModel(
        value: newPoints,
        userUid: currentUserUid,
        timestamp: DateTime.now(),
        type: 'recycle product',
        voucherId: null,
      );

      await transactionRepository.addDocument(transaction);

      // Success - navigate to home
      AppNavigator.navigateTo(page: BottomNavBar());

    } catch (error) {
      errorDialog(
        context: context,
        title: 'Error processing recycle: $error'
      );
    }
  }
}