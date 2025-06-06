import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/home_theme.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/modules/leaderboard/providers/leaderboard_provider.dart';

List memojiPaths = [
  'assets/memoji/1.png',
  'assets/memoji/2.png',
  'assets/memoji/3.png',
  'assets/memoji/4.png',
  'assets/memoji/5.png',
  'assets/memoji/6.png',
  'assets/memoji/7.png',
  'assets/memoji/8.png',
  'assets/memoji/9.png',
];

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  bool _showAllTime = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
      builder: (data) =>
        Scaffold(
          body: Stack(
            children: [
              // Background
              Stack(
                children: [
                  Positioned(
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/leaderboard/leaderboard3.png",
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          height: 25,
                          child: Image.asset(
                            "assets/leaderboard/line.png",
                            fit: BoxFit.fill,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              
              // List of other users
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 310,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: HomeAppTheme.background,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: FadeTransition(
                    opacity: _animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(_animation),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _showAllTime 
                          ? data.otherUsersAllTime.length 
                          : data.otherUsersGoal.length,
                        itemBuilder: (context, index) {
                          final item = _showAllTime 
                            ? data.otherUsersAllTime[index]
                            : data.otherUsersGoal[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 5,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24,
                                    alignment: Alignment.center,
                                    child: Text(
                                      (index + 4).toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 96, 96, 96),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color.fromARGB(255, 240, 240, 240),
                                    foregroundImage: AssetImage(memojiPaths[(index + 3) % 9]),
                                  ),
                                ],
                              ),
                              title: Text(
                                _showAllTime 
                                  ? (item as UserModel).name 
                                  : (item as UserWithGoalPoints).user.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: Container(
                                height: 28,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 240, 240, 240),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.token,
                                      color: Color.fromARGB(255, 255, 187, 0),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      _showAllTime 
                                        ? (item as UserModel).totalPoints.toString()
                                        : (item as UserWithGoalPoints).goalPoints.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.black,
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
                  ),
                ),
              ),
              
              // Header with integrated toggle
              Positioned(
                top: 45,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title on the left
                        const Text(
                          "Leaderboard",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Toggle on the right
                        _buildToggleSwitch(),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Top three - adjust positions
              FadeTransition(
                opacity: _animation,
                child: Stack(
                  children: [
                    // Rank 1st - moved up since we saved space
                    Positioned(
                      top: 110,
                      left: 140,
                      child: rank(
                        radius: 40,
                        height: 3,
                        image: "assets/memoji/1.png",
                        name: _getTopUserName(data, 0),
                        point: _getTopUserPoints(data, 0),
                        rank: 1,
                      ),
                    ),
                    // Rank 2nd - adjusted position
                    Positioned(
                      top: 170,
                      left: 45,
                      child: rank(
                        radius: 30.0,
                        height: 2,
                        image: "assets/memoji/2.png",
                        name: _getTopUserName(data, 1),
                        point: _getTopUserPoints(data, 1),
                        rank: 2,
                      ),
                    ),
                    // Rank 3rd - adjusted position
                    Positioned(
                      top: 190,
                      right: 45,
                      child: rank(
                        radius: 30.0,
                        height: 2,
                        image: "assets/memoji/3.png",
                        name: _getTopUserName(data, 2),
                        point: _getTopUserPoints(data, 2),
                        rank: 3,
                      ),
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
      width: 160, // Smaller width since it's now beside the title
      height: 32, // Smaller height
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
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
                  color: _showAllTime 
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  "All Time",
                  style: TextStyle(
                    fontSize: 11, // Smaller font
                    color: _showAllTime ? Colors.white : Colors.black54,
                    fontWeight: _showAllTime ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showAllTime ? _toggleLeaderboard : null,
              child: Container(
                decoration: BoxDecoration(
                  color: !_showAllTime 
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Goal",
                  style: TextStyle(
                    fontSize: 11, // Smaller font
                    color: !_showAllTime ? Colors.white : Colors.black54,
                    fontWeight: !_showAllTime ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  Column rank({
    required double radius,
    required double height,
    required String image,
    required String name,
    required String point,
    required int rank,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: const Color.fromARGB(255, 240, 240, 240),
              foregroundImage: AssetImage(image),
            ),
            if (rank == 1)
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.amber,
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 18,
                ),
              ),
          ],
        ),
        SizedBox(height: height),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: height),
        Container(
          height: 25,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(
                Icons.token,
                color: Color.fromARGB(255, 255, 187, 0),
                size: 16,
              ),
              Text(
                point,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
