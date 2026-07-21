import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

/// Skeleton placeholder mirroring the checkout screen's loaded layout:
/// delivery address card, store cards, payment method card, discount coupons
/// row, tip-your-driver card, invoice summary, notes field and the confirm
/// button. Card backgrounds stay static while their inner content shimmers,
/// matching [StoreDetailsShimmer].
class CheckoutShimmerView extends StatelessWidget {
  const CheckoutShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        children: [
          // Delivery Address card: title + edit action + address line.
          _ShimmerCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _SkeletonBox(width: 130, height: 16),
                    _SkeletonBox(width: 32, height: 14),
                  ],
                ),
                const _SkeletonBox(width: 150, height: 14),
              ],
            ),
          ),

          // Store cards: logo + name + chevron, product thumbnails, discount row.
          for (int i = 0; i < 2; i++)
            _ShimmerCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Row(
                    children: [
                      const _SkeletonBox(width: 48, height: 48, shape: BoxShape.circle),
                      12.wSpace,
                      const _SkeletonBox(width: 100, height: 16),
                      const Spacer(),
                      const _SkeletonBox(width: 20, height: 20),
                    ],
                  ),
                  Row(
                    spacing: 8,
                    children: const [
                      _SkeletonBox(width: 56, height: 56, radius: 6),
                      _SkeletonBox(width: 56, height: 56, radius: 6),
                    ],
                  ),
                  Row(
                    spacing: 12,
                    children: const [
                      Expanded(child: _SkeletonBox(height: 37, radius: 999)),
                      _SkeletonBox(width: 80, height: 37, radius: 999),
                    ],
                  ),
                ],
              ),
            ),

          // Choose payment method card: title + subtitle + trailing action box.
          _ShimmerCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: const [
                      _SkeletonBox(width: 160, height: 16),
                      _SkeletonBox(width: 90, height: 14),
                    ],
                  ),
                ),
                12.wSpace,
                const _SkeletonBox(width: 46, height: 46, radius: 6),
              ],
            ),
          ),

          // Discount coupons: horizontal list of ticket placeholders.
          AspectRatio(
            aspectRatio: 2,
            child: AppShimmer(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) => 16.wSpace,
                itemBuilder: (context, index) => Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: AppBorderRadius.brCircular16,
                  ),
                ),
              ),
            ),
          ),

          // Tip your driver: title + tip option pills + amount stepper.
          _ShimmerCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                const _SkeletonBox(width: 120, height: 16),
                Row(
                  spacing: 8,
                  children: const [
                    _SkeletonBox(width: 44, height: 44, radius: 999),
                    _SkeletonBox(width: 44, height: 44, radius: 999),
                    _SkeletonBox(width: 44, height: 44, radius: 999),
                    _SkeletonBox(width: 44, height: 44, radius: 999),
                    Expanded(child: _SkeletonBox(height: 44, radius: 999)),
                  ],
                ),
                const _SkeletonBox(height: 40, radius: 999),
              ],
            ),
          ),

          // Invoice summary: title + line items + divider + total.
          _ShimmerCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const _SkeletonBox(width: 130, height: 16),
                for (int i = 0; i < 4; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _SkeletonBox(width: 90, height: 14),
                      _SkeletonBox(width: 40, height: 14),
                    ],
                  ),
                Divider(
                  height: 2,
                  thickness: 1,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _SkeletonBox(width: 60, height: 14),
                    _SkeletonBox(width: 40, height: 14),
                  ],
                ),
              ],
            ),
          ),

          // Add notes field.
          const _ShimmerCard(
            padding: EdgeInsets.all(16),
            minHeight: 91,
            child: SizedBox(
              width: double.infinity,
              child: _SkeletonBox(width: 90, height: 14),
            ),
          ),

          // Confirm order button.
          const AppShimmer(
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A light-grey card matching the checkout cards' background/radius, with its
/// [child] shimmered on top.
class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({
    required this.child,
    required this.padding,
    this.minHeight = 0,
  });

  final Widget child;
  final EdgeInsets padding;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: padding,
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
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
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}
