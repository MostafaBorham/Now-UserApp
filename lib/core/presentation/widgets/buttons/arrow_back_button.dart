import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

/// Circular, transparent back button drawing the chevron asset.
///
/// Direction-agnostic on its own — wrap it in `ReverseWidget` where the arrow
/// has to flip with the locale.
class ArrowBackButton extends StatelessWidget {
  const ArrowBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Assets.media.images.svg.arrowRight.svg(width: 22, height: 22),
        ),
      ),
    );
  }
}
