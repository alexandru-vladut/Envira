import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/context_utils.dart';

class AppNavigator {

  static void pop({BuildContext? context}) {
    final ctx = ContextUtils.getSafeContext(context);
    if (ctx == null) return;

    Navigator.pop(ctx);
  }

  static void navigateTo({required Widget page, BuildContext? context}) {
    final ctx = ContextUtils.getSafeContext(context);
    if (ctx == null) return;

    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void navigateAndReplace({required Widget page, BuildContext? context}) {
    final ctx = ContextUtils.getSafeContext(context);
    if (ctx == null) return;

    Navigator.pushReplacement(
      ctx,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void navigateAndRemoveAll({required Widget page, BuildContext? context}) {
    final ctx = ContextUtils.getSafeContext(context);
    if (ctx == null) return;

    Navigator.pushAndRemoveUntil(
      ctx,
      MaterialPageRoute(builder: (_) => page),
      (_) => false,
    );
  }
}
