import 'package:flutter/material.dart';
import 'package:flutter_app_base/modules/profile/utils/styles.dart';

class Repository {

  static bool isDark = false;

  static Color bgColor(BuildContext context) {
    return isDark == true ? Styles.primaryColor : Styles.whiteColor;
  }

  static Color cardColor(BuildContext context) {
    return isDark == true ? Styles.greenColor : Styles.accentColor;
  }

  static Color cardColor2(BuildContext context) {
    return isDark == true ? Styles.accentColor : Styles.greenColor;
  }

  static Color navbarColor(BuildContext context) {
    return isDark == true ? Styles.primaryWithOpacityColor : Styles.whiteColor;
  }

  static Color selectedItemColor(BuildContext context) {
    return isDark == true ? Styles.blueColor : Styles.greenColor;
  }

  static Color textColor(BuildContext context) {
    return isDark == true ? Styles.whiteColor : Styles.primaryColor;
  }

  static Color fieldColor(BuildContext context) {
    return isDark == true ? Styles.whiteColor.withOpacity(0.5) : Colors.grey;
  }

  static Color headerColor(BuildContext context) {
    return isDark == true ? Styles.primaryColor : Styles.greenColor;
  }

  static Color dividerColor(BuildContext context) {
    return isDark == true ? Styles.primaryColor : Styles.greyColor;
  }

  static Color subTextColor(BuildContext context) {
    return isDark == true ? Styles.whiteColor.withOpacity(0.7) : Styles.primaryColor.withOpacity(0.7);
  }

  static Color iconColor(BuildContext context) {
    return isDark == true ? Styles.whiteColor.withOpacity(0.2) : Styles.greyColor;
  }

  static Color headerColor2(BuildContext context) {
    return isDark == true ? Styles.primaryWithOpacityColor : Styles.greenColor;
  }

  static Color accentColor(BuildContext context) {
    return isDark == true ? Styles.primaryWithOpacityColor : Styles.greyColor;
  }

  static Color accentColor2(BuildContext context) {
    return isDark == true ? Styles.primaryWithOpacityColor : Colors.transparent;
  }

  static Color notificationColor(BuildContext context) {
    return isDark == true ? Styles.whiteColor : Styles.primaryColor;
  }

  static Color thumbColor(BuildContext context) {
    return isDark == true ? Styles.blueColor : Styles.greyColor;
  }

  static Color activeColor(BuildContext context) {
    return isDark == true ? Styles.whiteColor : Styles.greyColor;
  }

  static Color titleColor(BuildContext context) {
    return isDark == true ? Styles.whiteColor : Styles.greenColor;
  }

}