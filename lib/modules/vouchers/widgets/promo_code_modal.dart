import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_base/data/models/voucher_model.dart';
import 'package:flutter_app_base/modules/vouchers/utils/code_generator.dart';
import 'package:flutter_app_base/modules/vouchers/utils/constants.dart';

class PromoCodeModal extends StatefulWidget {
  final VoucherModel voucher;

  const PromoCodeModal({
    super.key,
    required this.voucher,
  });

  /// Shows the promo code modal as a dialog
  static Future<void> show(BuildContext context, VoucherModel voucher) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Promo Code Dialog",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: PromoCodeModal(voucher: voucher),
            ),
          ),
        );
      },
    );
  }

  @override
  State<PromoCodeModal> createState() => _PromoCodeModalState();
}

class _PromoCodeModalState extends State<PromoCodeModal> with SingleTickerProviderStateMixin {
  late String _promoCode;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isCodeVisible = false;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    // Generate a partner-specific promo code
    _promoCode = CodeGenerator.generatePartnerCode(widget.voucher.partner);
    
    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  /// Toggles the visibility of the promo code
  void _toggleCodeVisibility() {
    setState(() {
      _isCodeVisible = !_isCodeVisible;
    });
    
    if (_isCodeVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  /// Copies the promo code to clipboard
  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: _promoCode));
    setState(() {
      _isCopied = true;
    });
    
    // Reset the copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String logoPath = partnerLogos[widget.voucher.partner] ?? partnerLogos['Default']!;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3881E0), Color(0xFF6C5CE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      logoPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Voucher details
                Text(
                  widget.voucher.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.voucher.partner,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Promo code section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  "Your Promo Code",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Use this code when making a purchase",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Promo code container with animation
                GestureDetector(
                  onTap: _copyCodeToClipboard,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3881E0).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Text(
                              _isCodeVisible ? _promoCode : "● ● ● ● ● ● ● ● ●",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3881E0),
                                letterSpacing: _isCodeVisible ? 1.0 : 3.0,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          _isCopied ? Icons.check_circle : Icons.content_copy,
                          color: _isCopied ? Colors.green : const Color(0xFF3881E0),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isCopied ? "Copied to clipboard!" : "Tap to copy",
                  style: TextStyle(
                    fontSize: 13,
                    color: _isCopied ? Colors.green : const Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action buttons - Using column instead of row to give more space
                Column(
                  children: [
                    _buildActionButton(
                      text: _isCodeVisible ? "Hide Code" : "Reveal Code",
                      icon: _isCodeVisible ? Icons.visibility_off : Icons.visibility,
                      onPressed: _toggleCodeVisibility,
                      isPrimary: false,
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      text: "Close",
                      icon: Icons.close,
                      onPressed: () => Navigator.of(context).pop(),
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Builds an action button with specified parameters
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: isPrimary ? const Color(0xFF3881E0) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isPrimary ? null : Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : const Color(0xFF666666),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 