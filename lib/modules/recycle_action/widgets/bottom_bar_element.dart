import 'package:flutter/material.dart';

class BottomBarElement extends StatelessWidget {
  final String imagePath;
  final String text;
  final dynamic value;

  const BottomBarElement({
    super.key,
    required this.imagePath,
    required this.text,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    int intValue = (value * 1000).toInt();

    return Column(
      children: <Widget>[
        Image.asset(imagePath, height: 30, color: Colors.white),
        const SizedBox(height: 3),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          (intValue != 0) ? '${intValue}g' : 'x',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}