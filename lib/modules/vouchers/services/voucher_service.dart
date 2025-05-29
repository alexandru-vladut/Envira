import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/models/voucher_model.dart';

class VoucherService{
  static Future<void> purchaseVoucher(
    BuildContext context,
    UserModel? user,
    VoucherModel voucher,
  ) async {

    loadingDialog(context: context);

    try {
      // Check if user is authenticated
      if (user == null) {
        errorDialog(
          context: context,
          title: 'Current user not found'
        );
        return;
      }

      // Check if user has enough points
      if (user.totalPoints < voucher.cost) {
        errorDialog(
          context: context,
          title: 'Insufficient points to purchase this voucher'
        );
        return;
      }

      // Update user's total points
      final newTotalPoints = user.totalPoints - voucher.cost;
      await userRepository.updateDocumentField(
        user.docId!,
        'totalPoints',
        newTotalPoints,
      );

      // Add voucher to user's vouchers list
      final updatedVoucherIds = List<String>.from(user.myVouchersIds)..add(voucher.docId!);
      await userRepository.updateDocumentField(
        user.docId!,
        'myVouchersIds',
        updatedVoucherIds,
      );

      AppNavigator.pop(); // Close loading dialog
      successDialog(
        context: context,
        title: 'Voucher purchased successfully!'
      );

    } catch (error) {
      AppNavigator.pop(); // Close loading dialog
      errorDialog(
        context: context,
        title: 'Error purchasing voucher: $error'
      );
    }
  }
}