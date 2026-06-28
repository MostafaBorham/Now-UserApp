import 'package:flutter/material.dart';

class WhiteGradientOverlayEffect extends StatelessWidget {
  const WhiteGradientOverlayEffect({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.55),
            Colors.white.withValues(alpha: 0.65),
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.95),
          ],
        ),
      ),
    );
  }
}