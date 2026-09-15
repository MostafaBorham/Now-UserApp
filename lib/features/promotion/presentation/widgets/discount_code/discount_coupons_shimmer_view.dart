import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/promotion/presentation/widgets/discount_code/discount_card_shimmer.dart';






class DiscountCouponsShimmerView extends StatelessWidget {
  const DiscountCouponsShimmerView({super.key, this.itemCount = 4});


  final int itemCount;

  static const double _cardGap = 16;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(



      padding: const EdgeInsets.only(top: 57),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: _cardGap),
      itemBuilder: (_, _) => const DiscountCardShimmer(),
    );
  }
}
