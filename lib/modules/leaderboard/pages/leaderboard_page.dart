import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/home_theme.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/modules/leaderboard/providers/leaderboard_provider.dart';
import 'dart:math' as math;

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
  
  // Colors for the vibrant design
  final Color _primaryBlue = const Color(0xFF3881E0);
  final Color _accentGold = const Color(0xFFFFBF00);
  final Color _vibrantPurple = const Color(0xFF8B5CF6);
  final Color _darkBlue = const Color(0xFF1A56DB);
  final Color _lightBlue = const Color(0xFFEBF5FF);

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
      builder: (data) =>
        Scaffold(
          body: Stack(
            children: [
              // Gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _lightBlue,
                      Colors.white,
                      HomeAppTheme.background.withOpacity(0.5),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
              
              // Decorative shapes
              Positioned(
                top: -30,
                right: -30,
                child: Transform.rotate(
                  angle: math.pi / 10,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 70,
                left: -15,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: _accentGold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              // List of other users with colorful card design
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 350,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(32),
                      topLeft: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _darkBlue.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: FadeTransition(
                    opacity: _animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(_animation),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.people_alt_rounded, 
                                    color: _primaryBlue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Competitors",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _darkBlue,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12, 
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _lightBlue,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.military_tech,
                                        color: _primaryBlue,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _showAllTime ? "All Time" : "Goal",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 0, bottom: 16),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _showAllTime 
                                ? data.otherUsersAllTime.length 
                                : data.otherUsersGoal.length,
                              itemBuilder: (context, index) {
                                final item = _showAllTime 
                                  ? data.otherUsersAllTime[index]
                                  : data.otherUsersGoal[index];
                                  
                                // Alternating card colors
                                final isEven = index % 2 == 0;
                                final cardColor = isEven 
                                  ? _lightBlue 
                                  : Colors.white;
                                
                                return Container(
                                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isEven ? _primaryBlue.withOpacity(0.1) : Colors.grey.shade100,
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, 
                                      vertical: 8,
                                    ),
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Rank indicator with gradient background
                                        Container(
                                          width: 32,
                                          height: 32,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                _primaryBlue.withOpacity(0.8),
                                                _vibrantPurple.withOpacity(0.8),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: _primaryBlue.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            (index + 4).toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Avatar with decorative border
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isEven ? _primaryBlue.withOpacity(0.3) : Colors.grey.shade300,
                                              width: 2,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.white,
                                            foregroundImage: AssetImage(memojiPaths[(index + 3) % 9]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      _showAllTime 
                                        ? (item as UserModel).name 
                                        : (item as UserWithGoalPoints).user.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _darkBlue,
                                      ),
                                    ),
                                    trailing: Container(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            _accentGold,
                                            const Color(0xFFE6A800),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _accentGold.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.token,
                                            color: Colors.white,
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
                                              color: Colors.white,
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
                ),
              ),
              
              // Header with custom painted background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _primaryBlue,
                        _vibrantPurple,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _darkBlue.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title with shadow
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Leaderboard",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Toggle switch
                      _buildToggleSwitch(),
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
                      child: Center(
                        child: _buildFirstPlace(data),
                      ),
                    ),
                    // Second place
                    Positioned(
                      top: 170,
                      left: 45,
                      child: _buildRunnerUp(data, 1, 2),
                    ),
                    // Third place
                    Positioned(
                      top: 190,
                      right: 45,
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
      width: 160,
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showAllTime ? null : _toggleLeaderboard,
              child: Container(
                decoration: BoxDecoration(
                  color: _showAllTime 
                    ? Colors.white
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  "All Time",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _showAllTime ? _primaryBlue : Colors.white,
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
                    ? Colors.white
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Goal",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: !_showAllTime ? _primaryBlue : Colors.white,
                  ),
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
                    _accentGold.withOpacity(0.6),
                    _accentGold.withOpacity(0.0),
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
                        color: _accentGold.withOpacity(0.3),
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
                border: Border.all(
                  color: _accentGold,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accentGold.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white,
                foregroundImage: AssetImage('assets/memoji/1.png'),
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
                      color: _accentGold.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _accentGold,
                      const Color(0xFFE6A800),
                    ],
                  ),
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
              color: _darkBlue,
            ),
          ),
        ),
        
        const SizedBox(height: 10),
        
        // Points with gradient background
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _accentGold,
                const Color(0xFFE6A800),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _accentGold.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.token,
                color: Colors.white,
                size: 20,
              ),
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
    final isSecond = rank == 2;
    
    return Column(
      children: [
        // Avatar with border
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSecond ? _primaryBlue : _vibrantPurple,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSecond ? _primaryBlue : _vibrantPurple).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                foregroundImage: AssetImage(isSecond ? 'assets/memoji/2.png' : 'assets/memoji/3.png'),
              ),
            ),
            
            // Rank badge
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSecond ? 
                    [_primaryBlue, const Color(0xFF2563EB)] : 
                    [_vibrantPurple, const Color(0xFF7C3AED)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSecond ? _primaryBlue : _vibrantPurple).withOpacity(0.3),
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
              color: isSecond ? _primaryBlue : _vibrantPurple,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Points
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSecond ? 
                [_primaryBlue, const Color(0xFF2563EB)] : 
                [_vibrantPurple, const Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isSecond ? _primaryBlue : _vibrantPurple).withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.token,
                color: Colors.white,
                size: 16,
              ),
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

