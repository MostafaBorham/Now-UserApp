import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/promotions/presentation/widgets/vouchers/voucher_ticket.dart';
import 'package:nowdelivery_user_app/features/promotions/presentation/widgets/vouchers/voucher_tickets_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';

/// The store-details discount-coupons strip: the store's coupons rendered as the
/// shared [VoucherTicket]s. Selection is radio behaviour — tapping a ticket
/// selects it (and clears any other), tapping the selected one again clears it.
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

    return VoucherTicketsList(
      itemCount: coupons.length,
      itemBuilder: (BuildContext context, int index, bool darkHead) {
        final CouponModel coupon = coupons[index];
        return VoucherTicket(
          discountValue: '${coupon.discountValue?.toInt() ?? 0}',
          isPercentage: coupon.isPercentage ?? true,
          name: coupon.name,
          validityText: _validity(context, coupon),
          darkHead: darkHead,
          isSelected: _selectedIndex == index,
          onTap: () => _select(index, coupon),
        );
      },
    );
  }

  String _validity(BuildContext context, CouponModel coupon) {
    final DateTime? startsAt = DateTime.tryParse(coupon.startsAt ?? '');
    final DateTime? expiresAt = DateTime.tryParse(coupon.expiresAt ?? '');
    final loc.DateFormat dateFormat = loc.DateFormat.yMMMMd(
      context.locale.toString(),
    );
    return [
      if (startsAt != null)
        '${LangKeys.fromKey.tr()} ${dateFormat.format(startsAt)}',
      if (expiresAt != null)
        '${LangKeys.toKey.tr()} ${dateFormat.format(expiresAt)}',
    ].join(' ');
  }
}
