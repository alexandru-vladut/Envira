import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
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

    // Filter users by company and role, then sort by points
    final leaderboardUsers = allUsers
      .where((user) => user.companyId == currentUser?.companyId)
      .where((user) => user.role != 'admin')
      .toList()
      ..sort((a, b) => (b.totalPoints).compareTo(a.totalPoints));

    // Split into top three and others
    final topThreeUsers = leaderboardUsers.take(3).toList();
    final otherUsers = leaderboardUsers.skip(3).toList();

    final leaderboardData = LeaderboardData(
      topThreeUsers: topThreeUsers,
      otherUsers: otherUsers,
    );

    return builder(leaderboardData);
  }
}

class LeaderboardData {
  final List<UserModel> topThreeUsers;
  final List<UserModel> otherUsers;

  const LeaderboardData({
    required this.topThreeUsers,
    required this.otherUsers,
  });
}
