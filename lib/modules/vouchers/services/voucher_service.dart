import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/models/voucher_model.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';

class VoucherService{

  // Inject UserRepository
  final UserRepository _userRepository;

  // Regular constructor
  VoucherService(this._userRepository);

  Future<void> purchaseVoucher(BuildContext context, UserModel? user, VoucherModel voucher) async {
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
      if (user.credits < voucher.cost) {
        errorDialog(
          context: context,
          title: 'Insufficient credits to purchase this voucher'
        );
        return;
      }

      // Update user's credits (subtract voucher cost)
      final updatedCredits = user.credits - voucher.cost;
      await _userRepository.updateDocumentField(
        user.docId!,
        'credits',
        updatedCredits,
      );

      // Add voucher to user's vouchers list
      final updatedVoucherIds = List<String>.from(user.myVouchersIds)..add(voucher.docId!);
      await _userRepository.updateDocumentField(
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

  Future<void> refundVoucher(BuildContext context, UserModel? user, VoucherModel voucher) async {
    loadingDialog(context: context);

    try {
      // Check if user is authenticated
      if (user == null) {
        AppNavigator.pop(); // Close loading dialog
        errorDialog(
          context: context,
          title: 'Current user not found'
        );
        return;
      }

      // Check if user actually owns this voucher
      if (!user.myVouchersIds.contains(voucher.docId!)) {
        AppNavigator.pop(); // Close loading dialog
        errorDialog(
          context: context,
          title: 'You do not own this voucher'
        );
        return;
      }

      // Update user's credits (add back the voucher cost)
      final updatedCredits = user.credits + voucher.cost;
      await _userRepository.updateDocumentField(
        user.docId!,
        'credits',
        updatedCredits,
      );

      // Remove voucher from user's vouchers list
      final updatedVoucherIds = List<String>.from(user.myVouchersIds)..remove(voucher.docId!);
      await _userRepository.updateDocumentField(
        user.docId!,
        'myVouchersIds',
        updatedVoucherIds,
      );

      AppNavigator.pop(); // Close loading dialog
      successDialog(
        context: context,
        title: 'Voucher refunded successfully! ${voucher.cost} points returned.'
      );

    } catch (error) {
      AppNavigator.pop(); // Close loading dialog
      errorDialog(
        context: context,
        title: 'Error refunding voucher: $error'
      );
    }
  }
}