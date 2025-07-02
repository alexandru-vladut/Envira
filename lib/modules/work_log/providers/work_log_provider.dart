import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/modules/work_log/providers/wfh_calculator.dart';
import 'package:flutter_app_base/data/models/company_model.dart';
import 'package:flutter_app_base/data/models/transaction_model.dart';
import 'package:flutter_app_base/data/providers/companies_provider.dart';
import 'package:flutter_app_base/data/providers/transactions_provider.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:provider/provider.dart';

class WorkLogProvider extends StatelessWidget {
  final Widget Function(WorkLogData data) builder;

  const WorkLogProvider({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    // Get current user UID
    final currentUserUid = context.select<AuthStateProvider, String?>((auth) => auth.uid,);

    // Get current user data from users provider
    final currentUser = context.read<UsersProvider>().items.firstWhereOrNull(
      (u) => u.uid == currentUserUid,
    );

    // Get current user's transactions
    final userTransactions = context
        .select<TransactionsProvider, List<TransactionModel>>((provider) => provider.items
          .where((t) => t.userUid == currentUserUid && t.workLogDate != null)
          .toList(),
        );

    // Extract unique logged dates from transactions (a list of DateTime)
    final loggedDates = userTransactions
      .map((t) => (t.workLogDate! as Timestamp).toDate())
      .toSet()
      .toList();

    if (currentUser!.transportMethod != 'not set' && currentUser.distanceToOffice > 0) {
      // Get company data
      final company = context.select<CompaniesProvider, CompanyModel?>((provider) => provider.items
        .firstWhereOrNull((c) => c.docId == currentUser.companyId),
      );

      // Calculate new points based on WFH calculator
      int newPoints = WFHCalculator.calculateSingleDayPoints(
        distanceToOfficeKm: currentUser.distanceToOffice,
        transportMethod: WFHCalculator.parseTransportMethod(currentUser.transportMethod),
        companyType: company!.type,
        region: company.region,
      );

      return builder(
        WorkLogData(
          loggedDates: loggedDates,
          newPoints: newPoints,
          distanceToOffice: currentUser.distanceToOffice,
          transportMethod: currentUser.transportMethod,
          companyType: company.type,
          companyRegion: company.region,
        ),
      );
    }

    return builder(WorkLogData(loggedDates: loggedDates));
  }
}

class WorkLogData {
  final List<DateTime> loggedDates;
  final int? newPoints;
  final int? distanceToOffice;
  final String? transportMethod;
  final String? companyType;
  final String? companyRegion;

  const WorkLogData({
    required this.loggedDates,
    this.newPoints,
    this.distanceToOffice,
    this.transportMethod,
    this.companyType,
    this.companyRegion,
  });
}
