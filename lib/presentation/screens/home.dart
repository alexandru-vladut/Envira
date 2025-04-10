import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/global_instances.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/presentation/screens/user_list_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final currentUid = context.select<AuthStateProvider, String?>((auth) => auth.uid);
    final currentUser = context.select<UsersProvider, UserModel?>(
      (provider) => provider.items.firstWhereOrNull((u) => u.uid == currentUid),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => authService.logOut(context),
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserListPage()),
                );
              },
              child: const Text("View All Users"),
            ),
          ],
        ),
      ),
    );
  }
}
