import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/selected_store_coupons_provider.dart';
import 'package:nowdelivery_user_app/features/promotions/presentation/widgets/vouchers/voucher_ticket.dart';
import 'package:nowdelivery_user_app/features/promotions/presentation/widgets/vouchers/voucher_tickets_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';

/// The store-details discount-coupons strip: the store's coupons rendered as the
/// shared [VoucherTicket]s.
///
/// A ticket is only tappable once this store has products in the cart — picking
/// a coupon means "apply it when I check this store out", which is meaningless
/// with nothing to check out. Until then the tickets are display-only.
///
/// Picking is radio behaviour per store: tapping a ticket records it as the
/// store's pick (replacing any other), tapping the picked one again clears it.
/// The pick lives in [selectedStoreCouponsProvider], which the store's checkout
/// card reads to apply the coupon on arrival.
class StoreDiscountCouponsList extends ConsumerWidget {
  const StoreDiscountCouponsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StoreModel store = ref.watch(storeProvider);
    final List<CouponModel> coupons = store.coupons ?? const [];

    if (coupons.isEmpty) return const SizedBox.shrink();

    final int? storeId = store.id;

    final bool inCart = ref.watch(
      getCartProvider.select(
        (AsyncValue<CartModel> cart) =>
            cart.valueOrNull?.vendors.any(
              (CartVendorModel vendor) => vendor.vendor.id == storeId,
            ) ??
            false,
      ),
    );

    final String? pickedCode = ref.watch(
      selectedStoreCouponsProvider.select(
        (Map<int, String> picks) => picks[storeId],
      ),
    );

    return VoucherTicketsList(
      itemCount: coupons.length,
      itemBuilder: (BuildContext context, int index, bool darkHead) {
        final CouponModel coupon = coupons[index];
        // No code means nothing checkout could apply, so it stays display-only
        // however full the cart is.
        final String? code = coupon.code;
        final bool tappable = inCart && storeId != null && code != null;
        return VoucherTicket(
          discountValue: '${coupon.discountValue?.toInt() ?? 0}',
          isPercentage: coupon.isPercentage ?? true,
          name: coupon.name,
          validityText: _validity(context, coupon),
          darkHead: darkHead,
          isSelected: code != null && code == pickedCode,
          onTap: tappable ? () => _pick(ref, storeId, code) : null,
        );
      },
    );
  }

  void _pick(WidgetRef ref, int storeId, String code) {
    ref
        .read(selectedStoreCouponsProvider.notifier)
        .update((Map<int, String> picks) {
          final Map<int, String> next = <int, String>{...picks};
          if (next[storeId] == code) {
            next.remove(storeId);
          } else {
            next[storeId] = code;
          }
          return next;
        });
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
