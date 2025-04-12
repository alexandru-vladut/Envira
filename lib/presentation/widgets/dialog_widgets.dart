import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/context_utils.dart';
import 'package:flutter_app_base/app/theme.dart';

void loadingDialog({BuildContext? context}) {
  final ctx = ContextUtils.getSafeContext(context);
  if (ctx == null) return;

  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (_) => const Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

void confirmDialog({
  BuildContext? context,
  required String title,
  required Function() onConfirm,
}) {
  final ctx = ContextUtils.getSafeContext(context);
  if (ctx == null) return;

  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: CustomTheme.darkBlue2.withSafeOpacity(0.2),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Cancel",
              style: TextStyle(
                fontSize: 18,
                color: CustomTheme.darkGrey,
                fontWeight: FontWeight.w600,
              )),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onConfirm();
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 132, 255),
          ),
          child: const Text(
            "Yes",
            style: TextStyle(
              fontSize: 18,
              color: CustomTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

void successDialog({
  BuildContext? context,
  required String title,
  String? text,
  String? confirmButtonText,
  Function()? onConfirm,
}) {
  final ctx = ContextUtils.getSafeContext(context);
  if (ctx == null) return;

  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.greenAccent.withSafeOpacity(0.2),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      content: text != null ? Text(text) : null,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            if (onConfirm != null) onConfirm();
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 73, 186, 143),
          ),
          child: Text(
            confirmButtonText ?? 'OK',
            style: const TextStyle(
              fontSize: 18,
              color: CustomTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

void errorDialog({
  BuildContext? context,
  required String title,
  String? text,
  String? confirmButtonText,
  Function()? onConfirm,
}) {
  final ctx = ContextUtils.getSafeContext(context);
  if (ctx == null) return;

  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.redAccent.withSafeOpacity(0.1),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      content: text != null ? Text(text) : null,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            if (onConfirm != null) onConfirm();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.redAccent,
          ),
          child: Text(
            confirmButtonText ?? 'OK',
            style: const TextStyle(
              fontSize: 18,
              color: CustomTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
