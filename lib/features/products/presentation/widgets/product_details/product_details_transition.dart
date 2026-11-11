import 'package:flutter/material.dart';

/// Owns one curve for the route lifetime, rather than a listener per frame.
class ProductDetailsTransition extends StatefulWidget {
  const ProductDetailsTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  static const enterDuration = Duration(milliseconds: 300);
  static const exitDuration = Duration(milliseconds: 240);

  final Animation<double> animation;
  final Widget child;

  @override
  State<ProductDetailsTransition> createState() =>
      _ProductDetailsTransitionState();
}

class _ProductDetailsTransitionState extends State<ProductDetailsTransition> {
  late CurvedAnimation _curve;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _attachAnimation();
  }

  void _attachAnimation() {
    _curve = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _position = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(_curve);
  }

  @override
  void didUpdateWidget(covariant ProductDetailsTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _curve.dispose();
      _attachAnimation();
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SlideTransition(
    position: _position,
    child: RepaintBoundary(child: widget.child),
  );
}
