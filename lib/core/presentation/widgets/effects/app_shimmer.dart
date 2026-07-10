import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Paints the app's shimmer loading effect over [child], masked to the exact
/// shape the child paints (rounded corners, circles, text, ...).
class AppShimmer extends StatelessWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final colors = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colors.onSurface.withValues(alpha: 0.6),
      highlightColor: colors.onSurface.withValues(alpha: 0.3),
      child: child,
    );
  }
}
