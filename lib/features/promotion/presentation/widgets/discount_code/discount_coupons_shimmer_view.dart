import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/promotion/presentation/widgets/discount_code/discount_card_shimmer.dart';

/// Full loading view for the discount-code screen.
///
/// Self-contained: renders a non-scrolling list of [DiscountCardShimmer]
/// placeholders, so the screen only needs to place a single instance of this
/// widget in its loading branch.
class DiscountCouponsShimmerView extends StatelessWidget {
  const DiscountCouponsShimmerView({super.key, this.itemCount = 4});

  /// Number of shimmer cards to render.
  final int itemCount;

  static const double _cardGap = 16;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // Matches the loaded list's top spacing so the loading and data states
      // line up under the AppWavedView wave (which drops the body's top padding
      // once a scroll controller is wired in).
      padding: const EdgeInsets.only(top: 57),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: _cardGap),
      itemBuilder: (_, _) => const DiscountCardShimmer(),
    );
  }
}
