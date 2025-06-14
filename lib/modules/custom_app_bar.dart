import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color titleColor;
  final double titleFontSize;
  final Color leadingIconColor;
  final Color leadingIconBackgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = CustomTheme.transparent,
    this.titleColor = CustomTheme.black,
    this.titleFontSize = 20,
    this.leadingIconColor = CustomTheme.black87,
    this.leadingIconBackgroundColor = CustomTheme.grey200,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: GestureDetector(
        onTap: () => AppNavigator.pop(context: context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: leadingIconBackgroundColor,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: leadingIconColor,
            size: 20,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}