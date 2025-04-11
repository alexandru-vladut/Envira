import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/theme.dart';

void loadingDialog(BuildContext context) {
  CoolAlert.show(
    context: context,
    type: CoolAlertType.loading,
    text: 'Loading...',
    barrierDismissible: false,
  );
}

void confirmDialog(BuildContext context, String title, Function() onConfirm) {
  CoolAlert.show(
    context: context,
    barrierDismissible: false,
    type: CoolAlertType.confirm,
    backgroundColor: CustomTheme.darkBlue2.withOpacity(0.2),
    confirmBtnColor: const Color.fromARGB(255, 0, 132, 255),
    confirmBtnText: 'Yes',
    showCancelBtn: true,
    title: title,
    titleTextStyle: const TextStyle(
      fontWeight: FontWeight.w600,
    ),
    cancelBtnTextStyle: const TextStyle(
      fontSize: 18,
      color: CustomTheme.darkGrey,
      fontWeight: FontWeight.w600,
    ),
    confirmBtnTextStyle: const TextStyle(
      fontSize: 18,
      color: CustomTheme.white,
      fontWeight: FontWeight.w600,
    ),
    onConfirmBtnTap: onConfirm,
  );
}

void successDialog({
  required BuildContext context,
  required String title,
  String? text,
  String? confirmButtonText,
  Function()? onConfirm,
}) {
  CoolAlert.show(
    context: context,
    barrierDismissible: false,
    type: CoolAlertType.success,
    backgroundColor: Colors.greenAccent.withOpacity(0.2),
    confirmBtnColor: const Color.fromARGB(255, 73, 186, 143),
    confirmBtnText: confirmButtonText ?? 'OK',
    title: title,
    titleTextStyle: const TextStyle(
      fontWeight: FontWeight.w600,
    ),
    text: text, // may be null for default behavior
    onConfirmBtnTap: onConfirm, // may be null for default behavior
  );
}

void errorDialog({
  required BuildContext context,
  required String title,
  String? text,
  String? confirmButtonText,
  Function()? onConfirm,
}) {
  CoolAlert.show(
    context: context,
    barrierDismissible: false,
    type: CoolAlertType.error,
    backgroundColor: Colors.redAccent.withOpacity(0.1),
    confirmBtnColor: Colors.redAccent,
    confirmBtnText: confirmButtonText ?? 'OK',
    title: title,
    titleTextStyle: const TextStyle(
      fontWeight: FontWeight.w600,
    ),
    text: text, // may be null for default behavior
    onConfirmBtnTap: onConfirm, // may be null for default behavior
  );
}
