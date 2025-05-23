import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UsersProvider>().items;

    return Scaffold(
      appBar: AppBar(title: const Text("All Users")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: Text(user.uid),
          );
        },
      ),
    );
  }
}
