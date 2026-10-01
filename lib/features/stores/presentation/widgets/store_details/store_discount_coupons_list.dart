import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/selected_store_coupons_provider.dart';
import 'package:nowdelivery_user_app/features/promotions/presentation/widgets/vouchers/voucher_ticket.dart';
import 'package:nowdelivery_user_app/features/promotions/presentation/widgets/vouchers/voucher_tickets_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';

/// The store-details discount-coupons strip: the store's coupons rendered as the
/// shared [VoucherTicket]s.
///
/// A ticket only picks once this store has products in the cart — picking a
/// coupon means "apply it when I check this store out", which is meaningless
/// with nothing to check out. Until then a tap explains that instead.
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
        final bool tappable = storeId != null && code != null;
        final bool isPercentage = coupon.isPercentage ?? true;
        return VoucherTicket(
          // A fixed-amount coupon is money and gets the two-decimal rule; a
          // percentage is a measurement and keeps one. `toInt()` truncated
          // both, so a 12.50 SAR coupon advertised itself as 12.
          discountValue: isPercentage
              ? '${formatDouble(coupon.discountValue)}'
              : formatMoney(coupon.discountValue),
          isPercentage: isPercentage,
          name: coupon.name,
          validityText: _validity(context, coupon),
          darkHead: darkHead,
          isSelected: code != null && code == pickedCode,
          onTap: !tappable
              ? null
              : inCart
              ? () => _pick(ref, storeId, code)
              : () => AppToast.showError(
                  context,
                  LangKeys.couponNeedsStoreInCartKey,
                ),
        );
      },
    );
  }

  void _pick(WidgetRef ref, int storeId, String code) {
    ref.read(selectedStoreCouponsProvider.notifier).update((
      Map<int, String> picks,
    ) {
      final Map<int, String> next = <int, String>{...picks};
      if (next[storeId] == code) {
        next.remove(storeId);
      } else {
        next[storeId] = code;
      }
      return next;
    });
  }

  /// Through the shared formatter, which converts to local time — formatting
  /// the parsed UTC value showed a timestamp's UTC date.
  String _validity(BuildContext context, CouponModel coupon) {
    final String start = context.getLocalizedApiDate(
      apiDateTimeStamp: coupon.startsAt,
    );
    final String end = context.getLocalizedApiDate(
      apiDateTimeStamp: coupon.expiresAt,
    );
    return [
      if (start.isNotEmpty) '${LangKeys.fromKey.tr()} $start',
      if (end.isNotEmpty) '${LangKeys.toKey.tr()} $end',
    ].join(' ');
  }
}
