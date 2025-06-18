import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/modules/environmental_impact/providers/env_impact_calculator.dart';
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

  const HomeDataProvider({super.key, required this.builder});

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
      (provider) =>provider.items.where((t) => t.userUid == currentUserUid).toList(),
    );

    // Get company data
    final company = context.select<CompaniesProvider, CompanyModel?>(
      (provider) => currentUser != null
        ? provider.items.firstWhereOrNull((c) => c.docId == currentUser.companyId)
        : null,
    );

    // Calculate derived data
    final homeData = _calculateData(
      currentUser: currentUser,
      allUsers: allUsers,
      userTransactions: userTransactions,
      company: company,
    );

    return builder(homeData);
  }

  // Calculate derived data
  HomeData _calculateData({
    required UserModel? currentUser,
    required List<UserModel> allUsers,
    required List<TransactionModel> userTransactions,
    required CompanyModel? company,
  }) {
    if (currentUser == null || company == null) {
      return const HomeData(
        userName: '',
        currentGoalPoints: -1,
        goalPoints: -1,
        allTimePoints: -1,
        goalCompletedPercentage: -1,
        emissionsSaved: -1,
        goalTimeLeft: -1,
        userRank: -1,
      );
    }

    // Calculate user rank (all-time)
    final companyUsers = allUsers
      .where((u) => u.companyId == currentUser.companyId && u.role != 'admin')
      .toList()
    ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    final userRank = companyUsers.indexWhere((u) => u.uid == currentUser.uid) + 1;

    // Calculate points from company goal created timestamp to goal deadline timestamp
    final int currentGoalPoints;
    final goalStartDate = company.goalCreatedTimestamp.toDate();
    final goalEndDate = company.goalDeadlineTimestamp.toDate();
    final currentGoalTransactions = userTransactions
            .where(
              (t) =>
                  t.timestamp.toDate().isAfter(goalStartDate) &&
                  t.timestamp.toDate().isBefore(goalEndDate) &&
                  t.value > 0,
            )
            .toList();
    currentGoalPoints = currentGoalTransactions.fold<int>(0, (sum, t) => sum + t.value);

    // Calculate percentage
    final goalCompletedPercentage =
        company.goalPoints > 0
            ? ((currentGoalPoints / company.goalPoints) * 100).toInt()
            : -1;

    // Calculate days remaining until goal deadline
    final int goalTimeLeft;
    final goalDeadline = company.goalDeadlineTimestamp.toDate();
    final now = DateTime.now();
    final difference = goalDeadline.difference(now);
    goalTimeLeft = difference.inDays;

    return HomeData(
      userName: currentUser.name,
      currentGoalPoints: currentGoalPoints,
      goalPoints: company.goalPoints,
      allTimePoints: currentUser.totalPoints,
      goalCompletedPercentage: goalCompletedPercentage,
      emissionsSaved: currentUser.totalPoints * EnvironmentalImpactCalculator.KG_CO2E_PER_POINT,
      goalTimeLeft: goalTimeLeft,
      userRank: userRank,
    );
  }
}

class HomeData {
  final String userName;
  final int currentGoalPoints;
  final int goalPoints;
  final int allTimePoints;
  final int goalCompletedPercentage;
  final double emissionsSaved;
  final int goalTimeLeft;
  final int userRank;

  const HomeData({
    required this.userName,
    required this.currentGoalPoints,
    required this.goalPoints,
    required this.allTimePoints,
    required this.goalCompletedPercentage,
    required this.emissionsSaved,
    required this.goalTimeLeft,
    required this.userRank,
  });
}
