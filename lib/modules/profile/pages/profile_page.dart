import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/theme/home_theme.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/dialog_widgets.dart';
import 'package:flutter_app_base/modules/profile/providers/profile_provider.dart';
import 'package:flutter_app_base/core/utils/memojis.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileProvider(
      builder: (data) => Scaffold(
        backgroundColor: HomeAppTheme.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _animation,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // Profile Header
                _buildProfileHeader(context, data),
                
                // Stats Section
                _buildStatsSection(context, data),
                
                // Settings Section
                _buildSettingsSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Column(
        children: [
          // Avatar and edit button
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Profile Avatar
              Hero(
                tag: 'profile_avatar',
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(55),
                    child: Image.asset(
                      Memojis.memoji1,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              // Edit Button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Edit profile action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit profile coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // User Name
          Text(
            (data.currentUser != null) ? data.currentUser!.name : 'User Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HomeAppTheme.darkerText,
            ),
          ),
          
          const SizedBox(height: 6),
          
          // User Email
          Text(
            (data.currentUser != null) ? data.currentUser!.email : 'user@example.com',
            style: const TextStyle(
              fontSize: 16,
              color: HomeAppTheme.lightText,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // User Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  (data.currentUser != null) ? data.currentUser!.role.toUpperCase() : 'USER',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, dynamic data) {
    final int totalPoints = (data.currentUser != null) ? data.currentUser!.totalPoints : 0;
    final int credits = (data.currentUser != null) ? data.currentUser!.credits : 0;
    final int vouchersCount = (data.currentUser != null) 
      ? data.currentUser!.myVouchersIds.length 
      : 0;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: HomeAppTheme.darkerText,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.eco,
                  iconColor: const Color(0xFF4CAF50),
                  value: totalPoints.toString(),
                  label: 'Points',
                ),
                _buildDivider(),
                _buildStatItem(
                  icon: Icons.token,
                  iconColor: const Color(0xFFFFB300),
                  value: credits.toString(),
                  label: 'Credits',
                ),
                _buildDivider(),
                _buildStatItem(
                  icon: Icons.redeem,
                  iconColor: const Color(0xFF3881E0),
                  value: vouchersCount.toString(),
                  label: 'Vouchers',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: HomeAppTheme.darkerText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: HomeAppTheme.darkerText,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.person,
                  iconColor: const Color(0xFF9C27B0),
                  title: 'Account Information',
                  onTap: () {
                    // Account info action
                  },
                ),
                _buildSettingItem(
                  icon: Icons.security,
                  iconColor: const Color(0xFF229e76),
                  title: 'Security',
                  onTap: () {
                    // Security action
                  },
                ),
                _buildSettingItem(
                  icon: Icons.contact_support,
                  iconColor: const Color(0xFFe17a0a),
                  title: 'Contact Support',
                  onTap: () {
                    // Contact support action
                  },
                ),
                _buildSettingItem(
                  icon: Icons.description,
                  iconColor: const Color(0xFF064c6d),
                  title: 'Terms & Conditions',
                  onTap: () {
                    // Terms action
                  },
                ),
                _buildSettingItem(
                  icon: Icons.logout,
                  iconColor: const Color(0xFFD32F2F),
                  title: 'Logout',
                  onTap: () {
                    confirmDialog(
                      title: "Are you sure you want to log out?",
                      onConfirm: () async => await authService.logOut(),
                    );
                  },
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: HomeAppTheme.darkText,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 60,
            endIndent: 16,
            color: Colors.grey.withOpacity(0.2),
          ),
      ],
    );
  }
} 