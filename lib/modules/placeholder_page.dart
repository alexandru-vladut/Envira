import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/core/theme/login_theme.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:provider/provider.dart';

class PlaceholderPage extends StatefulWidget {
  const PlaceholderPage({super.key});

  @override
  State<PlaceholderPage> createState() => _PlaceholderPageState();
}

class _PlaceholderPageState extends State<PlaceholderPage> {
  @override
  Widget build(BuildContext context) {
    final currentUserUid = context.select<AuthStateProvider, String?>((auth) => auth.uid);
    final currentUser = context.select<UsersProvider, UserModel?>(
      (provider) => provider.items.firstWhereOrNull((u) => u.uid == currentUserUid),
    );
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColorLight,
        title: const Text('Simple Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => confirmDialog(
                title: "Are you sure you want to log out?",
                onConfirm: () async => await authService.logOut(),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.all(13),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.logout, color: Colors.black),
              ),
            ),
            if (currentUser == null) ...[
              const CircularProgressIndicator(),
            ] else ...[
              Text('User ID: ${currentUser.uid}'),
              Text('User Name: ${currentUser.name}'),
              Text('User Email: ${currentUser.email}'),
              Text('User Pin: ${currentUser.pin ?? 'Not Set'}'),
            ],
          ],
        ),
      ),
    );
  }
}
