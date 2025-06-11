import 'package:flutter/material.dart';

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}

class CustomTheme {
  const CustomTheme();

  // New colors extracted from recycle_page.dart
  static const Color transparent = Colors.transparent;

  static const Color white = Color(0xFFFFFFFF);

  static const Color black = Color(0xFF000000);
  static const Color black87 = Color(0xDD000000);

  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color grey = Colors.grey;
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey800 = Color(0xFF424242);

  static const Color primaryGreen = Color(0xFF39BD65);

  static const Color lightBlue = Color(0xFFE3F2FD); // blue[50]
  static const Color lightBlueAccent = Color(0xFFBBDEFB); // blue[100]
  static const Color mediumBlue = Color(0xFF1976D2); // blue[700]

  static const Color errorRed = Color(0xFFEF5350); // red[400]
  static const Color errorRedDark = Color(0xFFD32F2F); // red[700]

  static const Color successGreen = Color(0xFF66BB6A); // green[400]
  static const Color successGreenDark = Color(0xFF388E3C); // green[600]
  static const Color lightGreenAccent = Color(0xFFE8F5E8); // green[50]
  static const Color lightGreenBorder = Color(0xFFC8E6C9); // green[200]

  static const Color blue = Color(0xFF049DD9);
  static const Color darkBlue1 = Color(0xFF055BA6);
  static const Color darkBlue2 = Color(0xFF023E73);
  static const Color darkBlue3 = Color.fromARGB(255, 14, 36, 64);

  static const Color blueGrey = Color(0xFF3A6D8C);
  static const Color darkGrey = Color.fromARGB(255, 67, 67, 67);

  static const Color dirtyWhite = Color(0xFFE9F0F2);

  static const Color loginButtonColor = Color.fromARGB(255, 32, 46, 65);
  static const Color cursorColor = Colors.black;

  static const Color gradientStart1 = Color.fromARGB(255, 12, 104, 184);
  static const Color gradientEnd1 = darkBlue3;

  static const Color gradientStart2 = Color.fromARGB(255, 154, 191, 214);
  static const Color gradientEnd2 = darkBlue3;

  static const Color cardStyle1 = Color.fromARGB(255, 42, 42, 42);
  static const Color cardStyle2 = Color(0xFF12E195);
  static const Color cardStyle3 = Color(0xFFAD88C6);
  static const Color cardStyle4 = Color(0xFFFFBE98);
  static const int cardStyleCount = 4;

  static const LinearGradient loginGradient = LinearGradient(
    colors: <Color>[gradientStart2, gradientEnd2],
    stops: <double>[0.0, 0.9],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
