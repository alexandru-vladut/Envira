import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/models/voucher_model.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/dialog_widgets.dart';
import 'package:flutter_app_base/modules/vouchers/utils/constants.dart';
import 'package:flutter_app_base/modules/vouchers/widgets/promo_code_modal.dart';

class AnimatedVoucherCard extends StatefulWidget {
  final VoucherModel voucher;
  final bool isAdded;
  final UserModel? currentUser;

  const AnimatedVoucherCard({
    super.key,
    required this.voucher,
    required this.isAdded,
    required this.currentUser,
  });

  @override
  State<AnimatedVoucherCard> createState() => _AnimatedVoucherCardState();
}

class _AnimatedVoucherCardState extends State<AnimatedVoucherCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  void _handleTap() async {
    if (widget.isAdded) {
      // Show promo code modal for claimed vouchers
      PromoCodeModal.show(context, widget.voucher);
    } else {
      // Purchase voucher for available vouchers
      await voucherService.purchaseVoucher(context, widget.currentUser, widget.voucher);
    }
  }
  
  void _handleActionButtonTap() async {
    if (widget.isAdded) {
      // Show refund confirmation for claimed vouchers
      confirmDialog(
        context: context,
        title: "Confirm Refund",
        message: "Are you sure you want to refund this voucher? You will receive ${widget.voucher.cost} points back.",
        confirmText: "Refund",
        confirmColor: Colors.red,
        confirmIcon: Icons.restore,
        onConfirm: () async {
          await voucherService.refundVoucher(context, widget.currentUser, widget.voucher);
        },
      );
    } else {
      // Purchase voucher for available vouchers
      await voucherService.purchaseVoucher(context, widget.currentUser, widget.voucher);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = widget.isAdded 
        ? const Color(0xFFF5F9FF) // Light blue for claimed vouchers
        : Colors.white;
    
    final Color borderColor = widget.isAdded
        ? const Color(0xFF3881E0) // Blue for claimed vouchers
        : Colors.transparent;
    
    final Color shadowColor = _isPressed
        ? widget.isAdded ? const Color(0xFF3881E0).withOpacity(0.1) : Colors.black.withOpacity(0.05)
        : widget.isAdded ? const Color(0xFF3881E0).withOpacity(0.2) : Colors.black.withOpacity(0.1);
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor,
                  width: widget.isAdded ? 1.5 : 0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    spreadRadius: 0,
                    blurRadius: _isPressed ? 5 : 10,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with logo, name, and action button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Partner Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                partnerLogos[widget.voucher.partner] ?? partnerLogos['Default']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Voucher Name and Partner
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.voucher.name,
                                style: const TextStyle(
                                  fontSize: 16, // Reduced from 18
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.voucher.partner,
                                style: TextStyle(
                                  fontSize: 13, // Reduced from 14
                                  fontWeight: FontWeight.w500,
                                  color: widget.isAdded 
                                    ? const Color(0xFF3881E0)
                                    : const Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Action Button
                        GestureDetector(
                          onTap: _handleActionButtonTap,
                          child: Container(
                            width: 28, // Reduced from 32
                            height: 28, // Reduced from 32
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isAdded ? Colors.red.shade400 : Colors.green.shade400,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.isAdded
                                      ? Colors.red.withOpacity(0.2)
                                      : Colors.green.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isAdded ? Icons.delete : Icons.add,
                              color: Colors.white,
                              size: 14, // Reduced from 16
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Description and Cost - now in separate rows to prevent overlap
                    const SizedBox(height: 10),
                    Text(
                      widget.voucher.description,
                      style: const TextStyle(
                        fontSize: 13, // Reduced from 14
                        color: Color(0xFF666666),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Points indicator at the bottom
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced padding
                        decoration: BoxDecoration(
                          color: widget.isAdded
                              ? const Color(0xFF3881E0).withOpacity(0.1)
                              : const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.isAdded ? Icons.check_circle : Icons.stars,
                              size: 14, // Reduced from 16
                              color: widget.isAdded
                                  ? const Color(0xFF3881E0)
                                  : const Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.voucher.cost} pts",
                              style: TextStyle(
                                fontSize: 13, // Reduced from 14
                                fontWeight: FontWeight.w600,
                                color: widget.isAdded
                                    ? const Color(0xFF3881E0)
                                    : const Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 