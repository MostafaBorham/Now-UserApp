import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupon_item.dart';

class StoreDiscountCouponsList extends ConsumerStatefulWidget {
  const StoreDiscountCouponsList({super.key, this.onCouponSelected});

  /// Called with the selected coupon, or null when the selection is cleared.
  final ValueChanged<CouponModel?>? onCouponSelected;

  @override
  ConsumerState<StoreDiscountCouponsList> createState() =>
      _StoreDiscountCouponsListState();
}

class _StoreDiscountCouponsListState
    extends ConsumerState<StoreDiscountCouponsList> {
  int? _selectedIndex;

  void _select(int index, CouponModel coupon) {
    // Radio behaviour: tapping the selected ticket again clears the selection.
    final bool isDeselecting = _selectedIndex == index;
    setState(() => _selectedIndex = isDeselecting ? null : index);
    widget.onCouponSelected?.call(isDeselecting ? null : coupon);
  }

  @override
  Widget build(BuildContext context) {
    final StoreModel store = ref.watch(storeProvider);
    final List<CouponModel> coupons = store.coupons ?? const [];

    if (coupons.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: coupons.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, index) => StoreDiscountCouponItem(
          coupon: coupons[index],
          storeName: context.getLocalizedApiText(store.name),
          darkHead: index.isOdd,
          isSelected: _selectedIndex == index,
          onTap: () => _select(index, coupons[index]),
        ),
      ),
    );
  }
}
