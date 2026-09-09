import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The shared card shell behind every FAQ row: a flat `#F5F5F5` fill with a soft
/// hairline drop shadow, rounded corners, and a clipped ink ripple. Used by both
/// [FaqTile] and the trailing "Other" tile so they stay identical.
class FaqCardShell extends StatelessWidget {
  const FaqCardShell({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(12);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.onPrimaryContainer,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: context.colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          // No ripple/highlight tint on expand/collapse — the card stays flat.
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: child,
          ),
        ),
      ),
    );
  }
}
