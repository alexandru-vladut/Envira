import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/home_theme.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/data/providers/vouchers_provider.dart';
import 'package:flutter_app_base/modules/vouchers/widgets/animated_voucher_card.dart';
import 'package:flutter_app_base/modules/vouchers/widgets/empty_vouchers_placeholder.dart';
import 'package:flutter_app_base/modules/vouchers/widgets/points_indicator.dart';
import 'package:flutter_app_base/modules/vouchers/widgets/section_header.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:provider/provider.dart';

class VouchersPage extends StatefulWidget {
  const VouchersPage({super.key});

  @override
  State<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = context.select<AuthStateProvider, String?>((auth) => auth.uid);
    final currentUser = context.select<UsersProvider, UserModel?>(
      (provider) => provider.items.firstWhereOrNull((u) => u.uid == currentUserUid),
    );
    final vouchers = context.watch<VouchersProvider>().items;
    
    final myVouchers = vouchers.where((voucher) => 
      currentUser?.myVouchersIds.contains(voucher.docId) ?? false
    ).toList();
    
    final availableVouchers = vouchers.where((voucher) => 
      !(currentUser?.myVouchersIds.contains(voucher.docId) ?? false)
    ).toList();

    return Scaffold(
      backgroundColor: HomeAppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vouchers',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF666666)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("About Vouchers"),
                  content: const Text("Vouchers can be claimed using points you earn. You can refund a voucher to get your points back."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Got it"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(_animation),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Points indicator
                if (currentUser != null)
                  PointsIndicator(points: currentUser.credits),
                
                // My Vouchers Section
                SectionHeader(
                  title: "My Vouchers",
                  icon: Icons.card_giftcard,
                  color: const Color(0xFF3881E0),
                  itemCount: myVouchers.length,
                ),
                
                if (myVouchers.isEmpty)
                  const EmptyVouchersPlaceholder(
                    title: "No Vouchers Yet",
                    message: "You haven't claimed any vouchers yet. Browse the available vouchers below and claim some!",
                    icon: Icons.card_giftcard,
                    color: Color(0xFF3881E0),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: myVouchers.length,
                    itemBuilder: (context, index) {
                      return AnimatedVoucherCard(
                        voucher: myVouchers[index],
                        isAdded: true,
                        currentUser: currentUser,
                      );
                    },
                  ),
                
                const SizedBox(height: 24),
                
                // Available Vouchers Section
                SectionHeader(
                  title: "Available Vouchers",
                  icon: Icons.storefront,
                  color: const Color(0xFF4CAF50),
                  itemCount: availableVouchers.length,
                ),
                
                if (availableVouchers.isEmpty)
                  const EmptyVouchersPlaceholder(
                    title: "All Claimed!",
                    message: "You've claimed all available vouchers. Check back later for new offers!",
                    icon: Icons.inventory_2,
                    color: Color(0xFF4CAF50),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: availableVouchers.length,
                    itemBuilder: (context, index) {
                      return AnimatedVoucherCard(
                        voucher: availableVouchers[index],
                        isAdded: false,
                        currentUser: currentUser,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
