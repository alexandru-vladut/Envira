import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:provider/provider.dart';

class ProfileProvider extends StatelessWidget {
  final Widget Function(ProfileData data) builder;

  const ProfileProvider({
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

    final profileData = ProfileData(
      currentUser: currentUser,
    );

    return builder(profileData);
  }
}

class ProfileData {
  final UserModel? currentUser;

  const ProfileData({
    required this.currentUser,
  });
}
