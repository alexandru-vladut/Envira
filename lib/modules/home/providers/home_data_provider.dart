import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/models/transaction_model.dart';
import 'package:flutter_app_base/data/models/company_model.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/data/providers/transactions_provider.dart';
import 'package:flutter_app_base/data/providers/companies_provider.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:provider/provider.dart';

class HomeDataProvider extends StatelessWidget {
  final Widget Function(HomeData data) builder;

  const HomeDataProvider({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Get current user UID
    final currentUserUid = context.select<AuthStateProvider, String?>((auth) => auth.uid);
    
    // Get current user data
    final currentUser = context.select<UsersProvider, UserModel?>(
      (provider) => provider.items.firstWhereOrNull((u) => u.uid == currentUserUid),
    );

    // Get all users for ranking calculation
    final allUsers = context.select<UsersProvider, List<UserModel>>(
      (provider) => provider.items,
    );

    // Get current user's transactions
    final userTransactions = context.select<TransactionsProvider, List<TransactionModel>>(
      (provider) => provider.items.where((t) => t.userUid == currentUserUid).toList(),
    );

    // Get company data
    final company = context.select<CompaniesProvider, CompanyModel?>(
      (provider) => currentUser != null 
        ? provider.items.firstWhereOrNull((c) => c.docId == currentUser.companyId)
        : null,
    );

    // Calculate derived data
    final calculatedData = _calculateData(
      currentUser: currentUser,
      allUsers: allUsers,
      userTransactions: userTransactions,
      company: company,
    );

    final homeData = HomeData(
      currentUser: currentUser,
      calculatedData: calculatedData,
    );

    return builder(homeData);
  }

  // Calculate derived data
  HomeCalculatedData _calculateData({
    required UserModel? currentUser,
    required List<UserModel> allUsers,
    required List<TransactionModel> userTransactions,
    required CompanyModel? company,
  }) {
    if (currentUser == null) {
      return const HomeCalculatedData(
        thisMonthPoints: -1,
        userRank: -1,
        thisMonthPercentage: -1,
      );
    }

    // Calculate this month's points
    final startOfCurrentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final thisMonthTransactions = userTransactions.where((t) => 
      t.timestamp.toDate().isAfter(startOfCurrentMonth) && t.value > 0
    ).toList();
    
    final thisMonthPoints = thisMonthTransactions.fold<int>(0, (sum, t) => sum + t.value);

    // Calculate user rank
    final companyUsers = allUsers
      .where((u) => u.companyId == currentUser.companyId && u.role != 'admin')
      .toList()
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    
    final userRank = companyUsers.indexWhere((u) => u.uid == currentUser.uid) + 1;

    // Calculate percentage
    final thisMonthPercentage = company != null && company.pointsGoal > 0
      ? ((thisMonthPoints / company.pointsGoal) * 100).toInt()
      : -1;

    return HomeCalculatedData(
      thisMonthPoints: thisMonthPoints,
      userRank: userRank,
      thisMonthPercentage: thisMonthPercentage,
    );
  }
}

class HomeData {
  final UserModel? currentUser;
  final HomeCalculatedData calculatedData;

  const HomeData({
    required this.currentUser,
    required this.calculatedData,
  });
}

class HomeCalculatedData {
  final int thisMonthPoints;
  final int userRank;
  final int thisMonthPercentage;

  const HomeCalculatedData({
    required this.thisMonthPoints,
    required this.userRank,
    required this.thisMonthPercentage,
  });
}