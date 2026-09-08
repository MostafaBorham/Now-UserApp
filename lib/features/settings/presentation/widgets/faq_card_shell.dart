import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The shared card shell behind every FAQ row: a `neutral200`-tinted fill with a
/// matching border and soft shadow, rounded corners, and a clipped ink ripple.
/// Used by both [FaqTile] and the trailing "Other" tile so they stay identical.
class FaqCardShell extends StatelessWidget {
  const FaqCardShell({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(16);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.neutral200.withValues(alpha: 0.5),
        borderRadius: radius,
        border: Border.all(color: context.colors.neutral200),
        boxShadow: [
          BoxShadow(
            color: context.colors.neutral200,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: child,
          ),
        ),
      ),
    );
  }
}
