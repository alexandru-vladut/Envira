import 'package:flutter/material.dart';

/// An animated button that provides visual feedback when pressed
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final double borderRadius;
  final bool hasShadow;
  final IconData? icon;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.width = double.infinity,
    this.height = 56.0,
    this.borderRadius = 12.0,
    this.hasShadow = true,
    this.icon,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
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
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.hasShadow 
                    ? [
                        BoxShadow(
                          color: widget.backgroundColor.withOpacity(_isPressed ? 0.4 : 0.2),
                          blurRadius: 8,
                          offset: Offset(0, _isPressed ? 2 : 4),
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.textColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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