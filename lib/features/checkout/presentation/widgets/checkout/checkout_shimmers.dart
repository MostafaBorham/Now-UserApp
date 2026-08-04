import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

/// Skeleton placeholder for the checkout screen's store cards, mirroring a
/// collapsed `CheckoutBrandItemCard`: logo + store name + chevron, the product
/// thumbnails row, and the discount-code row.
///
/// This and [InvoiceSummaryShimmer] are the only two loading states on the
/// checkout screen — every other widget renders its real self from the first
/// frame, since none of them needs the draft to be meaningful.
class CheckoutBrandCardsShimmer extends StatelessWidget {
  const CheckoutBrandCardsShimmer({super.key, this.cardsCount = 2});

  /// How many placeholder cards to draw. The real store count is unknown until
  /// the draft resolves, so this is a guess at the common case.
  final int cardsCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        for (int i = 0; i < cardsCount; i++)
          const _ShimmerCard(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Row(
                  children: [
                    _SkeletonBox(width: 48, height: 48, shape: BoxShape.circle),
                    SizedBox(width: 12),
                    _SkeletonBox(width: 100, height: 16),
                    Spacer(),
                    _SkeletonBox(width: 20, height: 20),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    _SkeletonBox(width: 56, height: 56, radius: 6),
                    _SkeletonBox(width: 56, height: 56, radius: 6),
                  ],
                ),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(child: _SkeletonBox(height: 37, radius: 999)),
                    _SkeletonBox(width: 80, height: 37, radius: 999),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Skeleton placeholder for `InvoiceSummaryCard`: the title, its four price
/// lines, the divider and the total row. Sized and coloured like the real card
/// so the swap to live totals doesn't shift the layout.
class InvoiceSummaryShimmer extends StatelessWidget {
  const InvoiceSummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return _ShimmerCard(
      padding: const EdgeInsets.all(16),
      color: colors.neutral500.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const _SkeletonBox(width: 130, height: 16),
          for (int i = 0; i < 4; i++)
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SkeletonBox(width: 90, height: 14),
                _SkeletonBox(width: 40, height: 14),
              ],
            ),
          Divider(
            height: 2,
            thickness: 1,
            color: colors.neutral500.withValues(alpha: 0.3),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SkeletonBox(width: 60, height: 14),
              _SkeletonBox(width: 40, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}

/// A card matching the checkout cards' background/radius, with its [child]
/// shimmered on top so only the inner content animates.
class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.child, required this.padding, this.color});

  final Widget child;
  final EdgeInsets padding;

  /// Defaults to the store-card background when omitted.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppShimmer(child: child),
    );
  }
}

/// A single black placeholder block, meant to be painted under an [AppShimmer].
class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    this.width,
    required this.height,
    this.radius = 4,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius),
      ),
    );
  }
}
