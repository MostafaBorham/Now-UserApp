import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

/// Full loading placeholder for the Address Details form.
///
/// Mirrors the real layout: the grey "Area" summary row, the Home/Work/Other
/// tab pill, the three address fields and the Save button — so the screen only
/// needs to drop a single instance of this widget into its loading branch.
class AddressDetailsShimmerView extends StatelessWidget {
  const AddressDetailsShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AppShimmer(
      child: Column(
        children: [
          // Area summary row: icon + two stacked text lines + "Change".
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.onSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const _ShimmerBox(width: 22, height: 22, radius: 11),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _ShimmerBox(width: 40, height: 12, radius: 4),
                      SizedBox(height: 6),
                      _ShimmerBox(width: 130, height: 16, radius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const _ShimmerBox(width: 52, height: 16, radius: 4),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Home / Work / Other tab pill.
          Container(
            height: 58,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(29),
            ),
            child: Row(
              children: List.generate(
                3,
                (_) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: colors.onSurface,
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),

          // Floor / Building / Instructions fields.
          const _ShimmerBox(width: double.infinity, height: 56, radius: 14),
          const SizedBox(height: 16),
          const _ShimmerBox(width: double.infinity, height: 56, radius: 14),
          const SizedBox(height: 16),
          const _ShimmerBox(width: double.infinity, height: 56, radius: 14),
          const SizedBox(height: 26),

          // Save Address button.
          const _ShimmerBox(width: double.infinity, height: 52, radius: 14),
        ],
      ),
    );
  }
}

/// A single rounded shimmer block, tinted from the theme's [ColorScheme].
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
