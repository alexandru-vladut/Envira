import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/models/company_model.dart';
import 'package:flutter_app_base/data/models/transaction_model.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/data/providers/companies_provider.dart';
import 'package:flutter_app_base/data/providers/transactions_provider.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:provider/provider.dart';

class LeaderboardProvider extends StatelessWidget {
  final Widget Function(LeaderboardData data) builder;

  const LeaderboardProvider({
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

    // Get all transactions
    final allTransactions = context.select<TransactionsProvider, List<TransactionModel>>(
      (provider) => provider.items,
    );

    // Get company data
    final company = context.select<CompaniesProvider, CompanyModel?>(
      (provider) => currentUser != null 
        ? provider.items.firstWhereOrNull((c) => c.docId == currentUser.companyId)
        : null,
    );

    // Calculate leaderboard data
    final leaderboardData = _calculateLeaderboardData(
      currentUser: currentUser,
      allUsers: allUsers,
      allTransactions: allTransactions,
      company: company,
    );

    return builder(leaderboardData);
  }

  LeaderboardData _calculateLeaderboardData({
    required UserModel? currentUser,
    required List<UserModel> allUsers,
    required List<TransactionModel> allTransactions,
    required CompanyModel? company,
  }) {
    if (currentUser == null || company == null) {
      return const LeaderboardData(
        topThreeUsersAllTime: [],
        otherUsersAllTime: [],
        topThreeUsersGoal: [],
        otherUsersGoal: [],
      );
    }

    // Filter users by company and role
    final companyUsers = allUsers
      .where((user) => user.companyId == currentUser.companyId)
      .where((user) => user.role != 'admin')
      .toList();

    // All-time leaderboard (based on totalPoints)
    final allTimeRanked = List<UserModel>.from(companyUsers)
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    final topThreeUsersAllTime = allTimeRanked.take(3).toList();
    final otherUsersAllTime = allTimeRanked.skip(3).toList();

    // Goal-based leaderboard
    final goalBasedUsers = companyUsers.map((user) {
      final goalPoints = _calculateUserGoalPoints(user, allTransactions, company);
      return UserWithGoalPoints(user: user, goalPoints: goalPoints);
    }).toList()
      ..sort((a, b) => b.goalPoints.compareTo(a.goalPoints));

    final topThreeUsersGoal = goalBasedUsers.take(3).toList();
    final otherUsersGoal = goalBasedUsers.skip(3).toList();

    return LeaderboardData(
      topThreeUsersAllTime: topThreeUsersAllTime,
      otherUsersAllTime: otherUsersAllTime,
      topThreeUsersGoal: topThreeUsersGoal,
      otherUsersGoal: otherUsersGoal,
    );
  }

  int _calculateUserGoalPoints(
    UserModel user,
    List<TransactionModel> allTransactions,
    CompanyModel company,
  ) {
    final goalStartDate = company.goalCreatedTimestamp.toDate();
    final goalEndDate = company.goalDeadlineTimestamp.toDate();
    
    final userGoalTransactions = allTransactions
      .where((t) => 
        t.userUid == user.uid &&
        t.timestamp.toDate().isAfter(goalStartDate) &&
        t.timestamp.toDate().isBefore(goalEndDate) &&
        t.value > 0)
      .toList();
    
    return userGoalTransactions.fold<int>(0, (sum, t) => sum + t.value);
  }
}

// Helper class to store user with their goal points
class UserWithGoalPoints {
  final UserModel user;
  final int goalPoints;

  UserWithGoalPoints({required this.user, required this.goalPoints});
}

class LeaderboardData {
  final List<UserModel> topThreeUsersAllTime;
  final List<UserModel> otherUsersAllTime;
  final List<UserWithGoalPoints> topThreeUsersGoal;
  final List<UserWithGoalPoints> otherUsersGoal;

  const LeaderboardData({
    required this.topThreeUsersAllTime,
    required this.otherUsersAllTime,
    required this.topThreeUsersGoal,
    required this.otherUsersGoal,
  });
}