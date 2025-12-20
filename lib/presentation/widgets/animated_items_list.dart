import 'package:flutter/material.dart';

class AnimatedItemsList extends StatelessWidget {
  final List<dynamic> items;
  final IndexedWidgetBuilder itemBuilder;
  final Duration duration;
  final Curve curve;

  const AnimatedItemsList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return SlideTransition(
          position: AlwaysStoppedAnimation(Offset.zero),
          child: FadeTransition(
            opacity: const AlwaysStoppedAnimation(1.0),
            child: itemBuilder(context, index),
          ),
        );
      },
    );
  }
}

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation.drive(Tween<double>(begin: 0.8, end: 1.0)),
      child: child,
    );
  }
}
