import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/utils/context_utils.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/dialog_animations.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/custom_loading_indicator.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/animated_button.dart';

/// Shows a loading dialog with an animated indicator
void loadingDialog({BuildContext? context, Color? color}) {
  final ctx = ContextUtils.getSafeContext(context);
  if (ctx == null) return;

  showGeneralDialog(
    context: ctx,
    barrierDismissible: false,
    barrierLabel: "Loading Dialog",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Container();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return DialogAnimations.fadeInUp(
        animation: animation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomLoadingIndicator(
                  color: color ?? CustomTheme.blue,
                  size: 50,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: CustomTheme.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Shows a confirmation dialog with animated buttons
void confirmDialog({
  BuildContext? context,
  required String title,
  String? message,
  required Function() onConfirm,
  String confirmText = "Yes",
  String cancelText = "Cancel",
  Color? confirmColor,
  IconData? confirmIcon,
}) {
  final ctx = ContextUtils.getSafeContext(context);
  if (ctx == null) return;

  showGeneralDialog(
    context: ctx,
    barrierDismissible: true,
    barrierLabel: "Confirm Dialog",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Container();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return DialogAnimations.bounceIn(
        animation: animation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.darkBlue2,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CustomTheme.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        text: cancelText,
                        backgroundColor: Colors.grey.shade200,
                        textColor: CustomTheme.darkGrey,
                        onPressed: () => Navigator.of(ctx).pop(),
                        height: 50,
                        borderRadius: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedButton(
                        text: confirmText,
                        backgroundColor: confirmColor ?? const Color.fromARGB(255, 0, 132, 255),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onConfirm();
                        },
                        icon: confirmIcon,
                        height: 50,
                        borderRadius: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Shows a success dialog with animation
void successDialog({
  BuildContext? context,
  required String title,
  String? text,
  String? confirmButtonText,
  Function()? onConfirm,
}) {
  final ctx = ContextUtils.getSafeContext(context);
  if (ctx == null) return;

  showGeneralDialog(
    context: ctx,
    barrierDismissible: false,
    barrierLabel: "Success Dialog",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Container();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return DialogAnimations.rotate3D(
        animation: animation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
              border: Border.all(
                color: Colors.green.shade100,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade400,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.darkBlue2,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (text != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CustomTheme.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                AnimatedButton(
                  text: confirmButtonText ?? 'OK',
                  backgroundColor: const Color.fromARGB(255, 73, 186, 143),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (onConfirm != null) onConfirm();
                  },
                  icon: Icons.check,
                  height: 50,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Shows an error dialog with animation
void errorDialog({
  BuildContext? context,
  required String title,
  String? text,
  String? confirmButtonText,
  Function()? onConfirm,
}) {
  final ctx = ContextUtils.getSafeContext(context);
  if (ctx == null) return;

  showGeneralDialog(
    context: ctx,
    barrierDismissible: false,
    barrierLabel: "Error Dialog",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Container();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return DialogAnimations.bounceIn(
        animation: animation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
              border: Border.all(
                color: Colors.red.shade100,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red.shade400,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.darkBlue2,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (text != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CustomTheme.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                AnimatedButton(
                  text: confirmButtonText ?? 'OK',
                  backgroundColor: Colors.redAccent,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (onConfirm != null) onConfirm();
                  },
                  icon: Icons.close,
                  height: 50,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

