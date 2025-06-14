import 'dart:math';
import 'package:flutter/material.dart';

/// A custom loading indicator with playful bounce animations
class CustomLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const CustomLoadingIndicator({
    super.key,
    this.color = Colors.blue,
    this.size = 40.0,
  });

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _rotationController;
  late List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();
    
    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    // Bounce animation controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    
    // Create 3 staggered animations for the bouncing dots
    _bounceAnimations = List.generate(3, (index) {
      final beginTime = index * 0.2;
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 0.4),
        TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 0.6),
      ]).animate(
        CurvedAnimation(
          parent: _bounceController,
          curve: Interval(
            beginTime,
            beginTime + 0.6,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.5,
      height: widget.size * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating ring
          RotationTransition(
            turns: _rotationController,
            child: Container(
              width: widget.size * 2.2,
              height: widget.size * 2.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withOpacity(0.2),
                  width: 4,
                ),
              ),
            ),
          ),
          
          // Inner pulsing circle
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_bounceController.value * 0.2),
                child: Container(
                  width: widget.size * 1.4,
                  height: widget.size * 1.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.1),
                  ),
                ),
              );
            },
          ),
          
          // Bouncing dots in a circle
          ...List.generate(3, (index) {
            final angle = (index * (2 * 3.14159 / 3)) + (_rotationController.value * 3.14159);
            final radius = widget.size * 0.8;
            final dx = radius * cos(angle);
            final dy = radius * sin(angle);
            
            return AnimatedBuilder(
              animation: _bounceAnimations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: Transform.scale(
                    scale: 0.6 + (_bounceAnimations[index].value * 0.5),
                    child: Container(
                      width: widget.size * 0.4,
                      height: widget.size * 0.4,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
} 