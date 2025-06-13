import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/app_config.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/dialog_widgets.dart';
import 'package:flutter_app_base/data/models/transaction_model.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/data/repositories/transaction_repository.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';
import 'package:flutter_app_base/modules/custom_nav_bar.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:provider/provider.dart';

class WorkLogService {
  // Inject repositories
  final UserRepository _userRepository;
  final TransactionRepository _transactionRepository;

  // Regular constructor
  WorkLogService(
    this._userRepository,
    this._transactionRepository,
  );
  
  Future<void> logWork(BuildContext context, DateTime date) async {
    loadingDialog(context: context);

    try {
      // Get current user UID from auth provider
      final currentUserUid = context.read<AuthStateProvider>().uid;
      if (currentUserUid == null) {
        AppNavigator.pop(); // Close loading dialog
        errorDialog(context: context, title: 'User not authenticated');
        return;
      }

      // Get current user data from users provider
      final currentUser = context.read<UsersProvider>().items.firstWhereOrNull(
        (u) => u.uid == currentUserUid,
      );

      if (currentUser == null) {
        AppNavigator.pop(); // Close loading dialog
        errorDialog(context: context, title: 'User data not found');
        return;
      }

      final newPoints = AppConfig.workFromHomePoints;
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

      TransactionModel transaction = TransactionModel(
        value: newPoints,
        userUid: currentUserUid,
        timestamp: DateTime.now(),
        workLogDate: date,
      );

      await _transactionRepository.addDocument(transaction);

      // Success - navigate to home
      AppNavigator.pop(); // Close loading dialog
      successDialog(
        context: context,
        title: 'Work log successful',
        text: 'You earned $newPoints points!',
        onConfirm: () {
          AppNavigator.pop(); // Close success dialog
          AppNavigator.navigateTo(page: CustomNavBar()); // Go to home
        },
      );
    } catch (error) {
      AppNavigator.pop(); // Close loading dialog
      errorDialog(context: context, title: 'Error processing work log: $error');
    }
  }
}
