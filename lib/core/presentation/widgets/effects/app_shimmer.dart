import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
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

    final AppColorScheme colors = context.colors;

    // A shimmer is a purely visual loading placeholder, so it must never react
    // to taps — otherwise the real [child]'s gestures (e.g. a card's onTap that
    // navigates) would fire while it is still just a skeleton. [IgnorePointer]
    // swallows every pointer event for any shimmer built through this widget.
    return IgnorePointer(
      child: Shimmer.fromColors(
        baseColor: colors.neutral500.withValues(alpha: 0.6),
        highlightColor: colors.neutral500.withValues(alpha: 0.3),
        child: child,
      ),
    );
  }
}
