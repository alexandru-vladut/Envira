import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/models/transaction_model.dart';
import 'package:flutter_app_base/data/providers/transactions_provider.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:provider/provider.dart';

class WorkLogProvider extends StatelessWidget {
  final Widget Function(WorkLogData data) builder;

  const WorkLogProvider({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    // Get current user UID
    final currentUserUid = context.select<AuthStateProvider, String?>(
      (auth) => auth.uid,
    );

    // Get current user's transactions
    final userTransactions = context
        .select<TransactionsProvider, List<TransactionModel>>(
          (provider) =>
              provider.items
                  .where(
                    (t) => t.userUid == currentUserUid && t.workLogDate != null,
                  )
                  .toList(),
        );

    // Extract unique logged dates from transactions (a list of DateTime)
    final loggedDates = userTransactions
      .map((t) => (t.workLogDate! as Timestamp).toDate())
      .toSet()
      .toList();

    final workLogData = WorkLogData(loggedDates: loggedDates);

    return builder(workLogData);
  }
}

class WorkLogData {
  final List<DateTime> loggedDates;

  const WorkLogData({required this.loggedDates});
}
