import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/dialog_widgets.dart';
import 'package:flutter_app_base/data/models/transaction_model.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/data/repositories/transaction_repository.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';
import 'package:flutter_app_base/modules/bottom_nav_bar.dart';
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
  
  Future<void> logWork(BuildContext context) async {
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

      final newPoints = 10;
      final updatedTotalPoints = currentUser.totalPoints + newPoints;

      // Update user's total points
      await _userRepository.updateDocumentField(
        currentUser.docId!,
        'totalPoints',
        updatedTotalPoints,
      );

      TransactionModel transaction = TransactionModel(
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
      errorDialog(context: context, title: 'Error processing work log: $error');
    }
  }
}
