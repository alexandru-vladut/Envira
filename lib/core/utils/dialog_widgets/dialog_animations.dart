import 'package:flutter/material.dart';

/// A collection of animations for dialog widgets
class DialogAnimations {
  /// Creates a bouncing entrance animation
  static Widget bounceIn({required Widget child, required Animation<double> animation}) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.elasticOut,
      reverseCurve: Curves.elasticIn,
    );
    
    return ScaleTransition(
      scale: curvedAnimation,
      child: child,
    );
  }
  
  /// Creates a fade-in and slide-up entrance animation
  static Widget fadeInUp({required Widget child, required Animation<double> animation}) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Creates a 3D rotation animation
  static Widget rotate3D({required Widget child, required Animation<double> animation}) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(3.14 * (1 - value)),
          alignment: Alignment.center,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Creates a pulse animation
  static Widget pulse({required Widget child}) {
    return PulseAnimationWidget(child: child);
  }
}

/// A widget that applies a continuous pulse animation to its child
class PulseAnimationWidget extends StatefulWidget {
  final Widget child;
  
  const PulseAnimationWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<PulseAnimationWidget> createState() => _PulseAnimationWidgetState();
}

class _PulseAnimationWidgetState extends State<PulseAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
} 