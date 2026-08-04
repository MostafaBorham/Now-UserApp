import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

/// White circular back button used on the plain (non-waved) tracking screens
/// (Order Confirmed, Payment Failed).
///
/// Mirrors the back affordance inside `AppWavedScaffold` but adds a soft shadow
/// so it stays legible on a white background.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap ?? () => context.pop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.neutral500.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Assets.media.images.svg.appBackArrow.svg(
            width: 18,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
