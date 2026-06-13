import 'package:flutter/material.dart';

class PriceCancelLine extends StatelessWidget {
  const PriceCancelLine({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Transform.rotate(
          angle: -0.3,
          child: Container(width: 30, height: 1, color: colors.inversePrimary),
        ),
      ],
    );
  }
}
