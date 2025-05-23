import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/models/user_model.dart';

class HomeHeader extends StatelessWidget {
  final UserModel? userData;

  const HomeHeader({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Hi, ',
                style: TextStyle(
                  color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.7),
                  fontSize: 28,
                )
              ),
              Text(
                userData?.name ?? '',
                style: TextStyle(
                  color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.7),
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
          Container(
            child: (userData != null) ?
              Image.asset(
                (userData!.companyId == '355aInOtLhMaQm6fyMCh') 
                  ? 'assets/images/singleton.png' 
                  : 'assets/images/technova.png',
                width: 200,
              )
              : const SizedBox(),
          )
        ],
      ),
    );
  }
}