import 'package:flutter/material.dart';

class ReverseWidget extends StatelessWidget {
  const ReverseWidget({
    super.key,
    required this.child, this.applyReverse = true,
  });

  final bool? applyReverse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return applyReverse!? Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(-1.0, 1.0),
      child: child,
    ) : child;
  }
}