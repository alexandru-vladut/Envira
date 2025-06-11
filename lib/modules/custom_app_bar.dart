import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CustomTheme.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: CustomTheme.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: GestureDetector(
        onTap: () => AppNavigator.pop(context: context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomTheme.grey200,
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: CustomTheme.black87,
            size: 20,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}