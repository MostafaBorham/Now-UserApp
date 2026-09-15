import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:shimmer/shimmer.dart';



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





    return IgnorePointer(
      child: Shimmer.fromColors(
        baseColor: colors.neutral500.withValues(alpha: 0.6),
        highlightColor: colors.neutral500.withValues(alpha: 0.3),
        child: child,
      ),
    );
  }
}
