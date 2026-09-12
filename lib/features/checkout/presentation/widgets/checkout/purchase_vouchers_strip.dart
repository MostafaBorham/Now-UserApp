import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_discounts_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/discount_code_item.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/data/models/purchase_voucher_model.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/viewmodel/get_purchase_vouchers_vm.dart';

/// The purchase-vouchers strip on the checkout screen.
///
/// Fetches vouchers for the checkout's vendor(s) and renders each as the shared
/// [DiscountCodeItem] ticket. A voucher applicable to this checkout is tappable
/// (tapping applies it to its vendor); others are dimmed. The applied voucher
/// gets a highlight border. Hidden entirely while loading, on error, or when
/// there are no vouchers.
class PurchaseVouchersStrip extends ConsumerWidget {
  const PurchaseVouchersStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<OrderModel> orders =
        ref.watch(
          checkoutModelProvider.select(
            (CheckoutModel? c) => c?.orderGroup.orders,
          ),
        ) ??
        const <OrderModel>[];

    final Set<int> vendorIds = <int>{
      for (final OrderModel order in orders)
        if (order.vendorId != null) order.vendorId!,
    };

    // Filter the list to this store when the checkout is single-vendor; fetch
    // everything for an all-stores checkout and resolve applicability per card.
    final int? storeId = vendorIds.length == 1 ? vendorIds.first : null;

    final List<PurchaseVoucherModel> vouchers =
        ref.watch(getPurchaseVouchersProvider(storeId)).valueOrNull ??
        const <PurchaseVoucherModel>[];

    if (vouchers.isEmpty) return const SizedBox.shrink();

    final List<AppliedDiscountModel> applied = ref.watch(
      appliedDiscountsProvider,
    );

    return SizedBox(
      height: 158,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        scrollDirection: Axis.horizontal,
        itemCount: vouchers.length,
        separatorBuilder: (_, _) => 16.wSpace,
        itemBuilder: (BuildContext context, int index) {
          final PurchaseVoucherModel voucher = vouchers[index];
          final int? targetVendorId = _resolveVendorId(voucher, vendorIds);
          final bool applicable = targetVendorId != null;

          final bool selected = applicable &&
              applied.any(
                (AppliedDiscountModel d) =>
                    d.vendorId == targetVendorId &&
                    d.isVoucher &&
                    d.code == voucher.code,
              );

          final Widget card = DiscountCodeItem(
            percentage: _discountText(voucher),
            storeName: _storeName(context, voucher),
            validity: _validity(context, voucher),
            isDimmed: !applicable,
            isSelected: selected,
          );

          if (!applicable) return card;

          return GestureDetector(
            onTap: () => _onTap(context, ref, voucher, targetVendorId),
            child: card,
          );
        },
      ),
    );
  }

  /// The vendor a voucher applies to within this checkout, or `null` if none.
  /// A store voucher targets the first of its stores present in the cart; a
  /// platform voucher targets the single checkout vendor, else the first.
  /// ponytail: first-vendor fallback for the rare platform + multi-vendor cart.
  int? _resolveVendorId(PurchaseVoucherModel voucher, Set<int> vendorIds) {
    if (vendorIds.isEmpty) return null;
    if (voucher.isPlatform) return vendorIds.first;
    for (final PurchaseVoucherStore store in voucher.stores) {
      if (vendorIds.contains(store.id)) return store.id;
    }
    return null;
  }

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    PurchaseVoucherModel voucher,
    int vendorId,
  ) async {
    final result = await ref
        .read(checkoutProvider.notifier)
        .applyPurchaseVoucher(vendorId: vendorId, code: voucher.code);

    if (!context.mounted) return;

    result.fold(
      // Voucher rejection reasons come back as raw untranslated keys, so never
      // surface the server text — show a generic message.
      (_) => AppToast.showError(context, LangKeys.voucherApplyFailedKey.tr()),
      (model) {
        if (!model.applied) {
          AppToast.showError(context, LangKeys.voucherApplyFailedKey.tr());
          return;
        }
        ref.read(appliedDiscountsProvider.notifier).add(
              AppliedDiscountModel(
                vendorId: vendorId,
                code: voucher.code,
                discount: model.discount,
                isVoucher: true,
              ),
            );
      },
    );
  }

  String _discountText(PurchaseVoucherModel voucher) {
    final double v = voucher.discountValue;
    final String value = v % 1 == 0 ? v.toInt().toString() : v.toString();
    return voucher.isPercentage ? '$value%' : value;
  }

  String _storeName(BuildContext context, PurchaseVoucherModel voucher) {
    if (voucher.isPlatform || voucher.stores.isEmpty) {
      return LangKeys.allStoresKey.tr();
    }
    return context.getLocalizedApiText(voucher.stores.first.name);
  }

  String _validity(BuildContext context, PurchaseVoucherModel voucher) {
    final String start = context.getLocalizedApiDate(
      apiDateTimeStamp: voucher.startsAt,
    );
    final String end = context.getLocalizedApiDate(
      apiDateTimeStamp: voucher.expiresAt,
    );
    return '$start - $end';
  }
}
