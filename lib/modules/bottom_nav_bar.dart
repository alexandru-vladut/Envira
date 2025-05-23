import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/login_theme.dart';
import 'package:flutter_app_base/modules/home/pages/home_page.dart';
import 'package:flutter_app_base/modules/placeholder_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  List<Widget> widgetOptions = [];

  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    setState(() {
      widgetOptions = <Widget>[
        HomePage(animationController: animationController),
        const PlaceholderPage(),
        const PlaceholderPage(),
        const PlaceholderPage(),
        // const VouchersPage(),
        // const LeaderboardPage(),
        // const Profile()
      ];
    });

    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 24,
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kBackgroundColor, // Repository.selectedItemColor(context),
        unselectedItemColor: Colors.grey.withOpacity(0.7),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.redeem_rounded),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
