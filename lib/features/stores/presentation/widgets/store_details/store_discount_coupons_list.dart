import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupon_item.dart';

class StoreDiscountCouponsList extends ConsumerWidget {
  const StoreDiscountCouponsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CouponModel> coupons =
        ref.watch(storeProvider).coupons ?? const [];

    if (coupons.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: coupons.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) =>
            StoreDiscountCouponItem(coupon: coupons[index]),
      ),
    );
  }
}
