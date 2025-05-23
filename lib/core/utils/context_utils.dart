import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';

class ContextUtils {
  static BuildContext? getSafeContext([BuildContext? contextOverride]) {
    final ctx = contextOverride ?? navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted){
      logger.e("[ERROR - getSafeContext()] Context is null or not mounted.");
      return null;
    }
    return ctx;
  }
}
