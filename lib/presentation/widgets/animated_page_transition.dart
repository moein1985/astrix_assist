import 'package:flutter/material.dart';

class AnimatedPageTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedPageTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final fadeAnimation = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    ) as Widget;
  }
}

class HeroPageTransition extends StatelessWidget {
  final Widget child;
  final String tag;

  const HeroPageTransition({
    super.key,
    required this.child,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: child,
    );
  }
}
