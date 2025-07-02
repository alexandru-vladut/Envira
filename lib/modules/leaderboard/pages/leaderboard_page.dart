import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/home_theme.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/modules/leaderboard/providers/leaderboard_provider.dart';
import 'dart:math' as math;

import 'package:flutter_app_base/core/utils/memojis.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  bool _showAllTime = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Colors for the unified design
  final Color _accentGold = const Color(0xFFFFBF00);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLeaderboard() {
    setState(() {
      _showAllTime = !_showAllTime;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LeaderboardProvider(
      builder:
          (data) => Scaffold(
            backgroundColor: HomeAppTheme.white,
            body: Stack(
              children: [
                // List of other users with gradient background
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 330,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: CustomTheme.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(32),
                        topLeft: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CustomTheme.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                          child: _buildToggleSwitch(),
                        ),

                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 0, bottom: 16),
                            physics: const BouncingScrollPhysics(),
                            itemCount:
                                _showAllTime
                                    ? data.otherUsersAllTime.length
                                    : data.otherUsersGoal.length,
                            itemBuilder: (context, index) {
                              final item =
                                  _showAllTime
                                      ? data.otherUsersAllTime[index]
                                      : data.otherUsersGoal[index];

                              bool isCurrentUser = (data.currentUser != null && (data.currentUser!.uid == (item as UserModel).uid));

                              Color accentColor = isCurrentUser ? _accentGold : HomeAppTheme.lightText;

                              return Container(
                                margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                decoration: BoxDecoration(
                                  color: CustomTheme.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: accentColor.withOpacity(0.2),
                                    width: isCurrentUser ? 1 : 0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CustomTheme.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.only(left: 4, right: 16, top: 8, bottom: 8),
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Rank indicator
                                      Text(
                                        "${index + 4}",
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(255, 210, 215, 217),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Avatar
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: CustomTheme.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor:
                                              CustomTheme.transparent,
                                          foregroundImage: AssetImage(
                                            memojiPaths[(index + 3) % 9],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    _showAllTime
                                        ? (item as UserModel).name
                                        : (item as UserWithGoalPoints).user.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: CustomTheme.black,
                                    ),
                                  ),
                                  trailing: Container(
                                    height: 36,
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentColor.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.token,
                                          color: CustomTheme.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _showAllTime
                                              ? (item as UserModel).totalPoints.toString()
                                              : (item as UserWithGoalPoints).goalPoints.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: CustomTheme.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Header with clean design
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: MediaQuery.of(context).padding.top + 10,
                      bottom: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Text(
                          "Leaderboard",
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        // Toggle switch
                        // _buildToggleSwitch(),
                      ],
                    ),
                  ),
                ),

                // Top three with animations and decorative elements
                FadeTransition(
                  opacity: _animation,
                  child: Stack(
                    children: [
                      // First place winner with special effects
                      Positioned(
                        top: 110,
                        left: 0,
                        right: 0,
                        child: Center(child: _buildFirstPlace(data)),
                      ),
                      // Second place
                      Positioned(
                        top: 170,
                        left: 35,
                        child: _buildRunnerUp(data, 1, 2),
                      ),
                      // Third place
                      Positioned(
                        top: 180,
                        right: 35,
                        child: _buildRunnerUp(data, 2, 3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: CustomTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showAllTime ? null : _toggleLeaderboard,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      _showAllTime
                          ? CustomTheme.primaryGreen
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: _showAllTime ? Colors.white : CustomTheme.black,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "All Time",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _showAllTime ? Colors.white : CustomTheme.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showAllTime ? _toggleLeaderboard : null,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      !_showAllTime
                          ? CustomTheme.primaryGreen
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      color: !_showAllTime ? Colors.white : CustomTheme.black,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Goal",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: !_showAllTime ? Colors.white : CustomTheme.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstPlace(LeaderboardData data) {
    final name = _getTopUserName(data, 0);
    final points = _getTopUserPoints(data, 0);

    Color accentColor = _isCurrentUserTop(data, 0) ? _accentGold : HomeAppTheme.lightText;

    return Column(
      children: [
        // Profile picture with glow and decoration
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withOpacity(0.6),
                    accentColor.withOpacity(0.0),
                  ],
                  radius: 0.55,
                ),
              ),
            ),
            // Animated rotation for decorative ring
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 2 * math.pi),
              duration: const Duration(seconds: 10),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value,
                  child: Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: const SizedBox(),
                  ),
                );
              },
            ),
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white,
                foregroundImage: AssetImage(Memojis.memoji1),
              ),
            ),
            // First place badge
            Positioned(
              bottom: 0,
              right: 5,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                  color: accentColor,
                ),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    "1",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Name with special style
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: CustomTheme.black,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Points with gold background
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.token, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                points,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRunnerUp(LeaderboardData data, int index, int rank) {
    final name = _getTopUserName(data, index);
    final points = _getTopUserPoints(data, index);

    Color accentColor = _isCurrentUserTop(data, index) ? _accentGold : HomeAppTheme.lightText;

    return Column(
      children: [
        // Avatar with border
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                foregroundImage: AssetImage(
                  rank == 2 ? Memojis.memoji2 : Memojis.memoji3,
                ),
              ),
            ),

            // Rank badge
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.transparent,
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: CustomTheme.black,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Points
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accentColor,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.token, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                points,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isCurrentUserTop(LeaderboardData data, int index) {
    if (_showAllTime) {
      return data.currentUser != null &&
          data.topThreeUsersAllTime.length > index &&
          data.topThreeUsersAllTime[index].uid == data.currentUser!.uid;
    } else {
      return data.currentUser != null &&
          data.topThreeUsersGoal.length > index &&
          data.topThreeUsersGoal[index].user.uid == data.currentUser!.uid;
    }
  }

  String _getTopUserName(LeaderboardData data, int index) {
    if (_showAllTime) {
      final list = data.topThreeUsersAllTime;
      if (list.length > index) {
        return (list[index]).name;
      }
    } else {
      final list = data.topThreeUsersGoal;
      if (list.length > index) {
        return (list[index]).user.name;
      }
    }
    return "N/A";
  }

  String _getTopUserPoints(LeaderboardData data, int index) {
    if (_showAllTime) {
      final list = data.topThreeUsersAllTime;
      if (list.length > index) {
        return (list[index]).totalPoints.toString();
      }
    } else {
      final list = data.topThreeUsersGoal;
      if (list.length > index) {
        return (list[index]).goalPoints.toString();
      }
    }
    return "0";
  }
}
