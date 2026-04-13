import 'package:flutter/material.dart';

/// Wraps any widget (usually a button) with a subtle scale-down animation on press.
class AnimatedPressWrapper extends StatefulWidget {
  final Widget child;
  const AnimatedPressWrapper({super.key, required this.child});

  @override
  State<AnimatedPressWrapper> createState() => _AnimatedPressWrapperState();
}

class _AnimatedPressWrapperState extends State<AnimatedPressWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _controller.forward(),
      onPointerUp: (_) => _controller.reverse(),
      onPointerCancel: (_) => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
