import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/modules/profile/utils/repository.dart';

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? callback;
  final Color color;
  final BuildContext context;

  const CustomListTile(
      {super.key, required this.icon,
        required this.title,
        this.callback,
        required this.color,
        required this.context});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Repository.accentColor(context),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 30),
      ),
      minLeadingWidth: 50,
      horizontalTitleGap: 13,
      title: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Repository.textColor(context))),
      trailing: Icon(CupertinoIcons.arrow_right,
          color: Repository.textColor(context)),
      onTap: callback,
    );  }
}