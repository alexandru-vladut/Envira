import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/home_theme.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Hi, ',
                style: TextStyle(
                  color: HomeAppTheme.lightText,
                  fontSize: 28,
                )
              ),
              Text(
                userName,
                style: TextStyle(
                  color: HomeAppTheme.lightText,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                )
              ),
              Text(
                '.',
                style: TextStyle(
                  color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.7),
                  fontSize: 28,
                )
              ),
            ],
          ),
          Image.asset(
            'assets/images/technova_crop.png',
            width: 150,
          )
        ],
      ),
    );
  }
}