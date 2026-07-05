import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupon_item.dart';

class StoreDiscountCouponsList extends StatelessWidget {
  const StoreDiscountCouponsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) => const StoreDiscountCouponItem(),
      ),
    );
  }
}
