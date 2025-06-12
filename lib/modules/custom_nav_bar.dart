import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/home_theme.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/modules/home/pages/home_page.dart';
import 'package:flutter_app_base/modules/leaderboard/pages/leaderboard_page.dart';
import 'package:flutter_app_base/modules/profile/pages/profile_page.dart';
import 'package:flutter_app_base/modules/vouchers/pages/vouchers_page.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  List<Widget> widgetOptions = [];

  AnimationController? animationController;
  late AnimationController _iconAnimationController;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Start with animation completed for initial tab
    _iconAnimationController.value = 1.0;

    setState(() {
      widgetOptions = <Widget>[
        HomePage(animationController: animationController),
        const VouchersPage(),
        const LeaderboardPage(),
        const ProfilePage()
      ];
    });

    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _iconAnimationController.reset();
      _iconAnimationController.forward();
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BackdropFilter(
            filter: ColorFilter.mode(
              Colors.white.withOpacity(0.8),
              BlendMode.srcOver,
            ),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0.9),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: CustomTheme.primaryGreenDark,
              unselectedItemColor: HomeAppTheme.lightText,
              items: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.redeem_rounded, 'Vouchers', 1),
                _buildNavItem(Icons.leaderboard_rounded, 'Leaderboard', 2),
                _buildNavItem(Icons.person_rounded, 'Profile', 3),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    
    return BottomNavigationBarItem(
      icon: Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: AnimatedBuilder(
          animation: _iconAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected 
                  ? 1.0 + (_iconAnimationController.value * 0.15) 
                  : 1.0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? CustomTheme.primaryGreenDark.withOpacity(0.1) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 24 : 22,
                ),
              ),
            );
          },
        ),
      ),
      label: label,
    );
  }
}
