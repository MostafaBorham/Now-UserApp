import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/blocking_loading_overlay.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_discounts_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_discount_vm.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/promotions/presentation/widgets/vouchers/voucher_ticket.dart';
import 'package:nowdelivery_user_app/features/promotions/presentation/widgets/vouchers/voucher_tickets_list.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/data/models/purchase_voucher_model.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/viewmodel/get_purchase_vouchers_vm.dart';













class PurchaseVouchersStrip extends ConsumerStatefulWidget {
  const PurchaseVouchersStrip({super.key});

  @override
  ConsumerState<PurchaseVouchersStrip> createState() =>
      _PurchaseVouchersStripState();
}

class _PurchaseVouchersStripState extends ConsumerState<PurchaseVouchersStrip> {



  String? _applyingKey;

  String _voucherKey(int vendorId, String code) => '$vendorId:$code';

  @override
  Widget build(BuildContext context) {
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



    final int? storeId = vendorIds.length == 1 ? vendorIds.first : null;

    final List<PurchaseVoucherModel> vouchers =
        ref.watch(getPurchaseVouchersProvider(storeId)).valueOrNull ??
        const <PurchaseVoucherModel>[];

    if (vouchers.isEmpty) return const SizedBox.shrink();

    final List<AppliedDiscountModel> applied = ref.watch(
      appliedDiscountsProvider,
    );



    final bool isApplying = _applyingKey != null;

    return VoucherTicketsList(
      itemCount: vouchers.length,
      itemBuilder: (BuildContext context, int index, bool darkHead) {
        final PurchaseVoucherModel voucher = vouchers[index];
        final int? targetVendorId = _resolveVendorId(voucher, vendorIds);
        final bool applicable = targetVendorId != null;

        final bool selected =
            applicable &&
            applied.any(
              (AppliedDiscountModel d) =>
                  d.vendorId == targetVendorId &&
                  d.isVoucher &&
                  d.code == voucher.code,
            );

        final bool isLoading =
            applicable &&
            _applyingKey == _voucherKey(targetVendorId, voucher.code);



        final bool tappable = applicable && !isApplying;



        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BlockingLoadingOverlay(
            isLoading: isLoading,
            child: VoucherTicket(
              discountValue: _discountText(voucher),
              isPercentage: voucher.isPercentage,
              name: voucher.name,
              validityText: _validity(context, voucher),
              darkHead: darkHead,
              isDimmed: !applicable,
              isSelected: selected,
              onTap: tappable
                  ? () => _onTap(voucher, targetVendorId, selected)
                  : null,
            ),
          ),
        );
      },
    );
  }





  int? _resolveVendorId(PurchaseVoucherModel voucher, Set<int> vendorIds) {
    if (vendorIds.isEmpty) return null;
    if (voucher.isPlatform) return vendorIds.first;
    for (final PurchaseVoucherStore store in voucher.stores) {
      if (vendorIds.contains(store.id)) return store.id;
    }
    return null;
  }

  Future<void> _onTap(
    PurchaseVoucherModel voucher,
    int vendorId,
    bool selected,
  ) async {



    if (selected) {
      ref.read(appliedDiscountsProvider.notifier).remove(vendorId);
      return;
    }


    setState(() => _applyingKey = _voucherKey(vendorId, voucher.code));

    final result = await ref
        .read(checkoutDiscountProvider)
        .applyPurchaseVoucher(vendorId: vendorId, code: voucher.code);

    if (!mounted) return;



    setState(() => _applyingKey = null);

    result.fold(



      (_) => AppToast.showError(context, LangKeys.voucherApplyFailedKey.tr()),
      (model) {
        if (!model.applied) {
          AppToast.showError(context, LangKeys.voucherApplyFailedKey.tr());
          return;
        }
        ref
            .read(appliedDiscountsProvider.notifier)
            .add(
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
    return v % 1 == 0 ? v.toInt().toString() : v.toString();
  }



  String _validity(BuildContext context, PurchaseVoucherModel voucher) {
    final String start = context.getLocalizedApiDate(
      apiDateTimeStamp: voucher.startsAt,
    );
    final String end = context.getLocalizedApiDate(
      apiDateTimeStamp: voucher.expiresAt,
    );
    return [
      if (start.isNotEmpty) '${LangKeys.fromKey.tr()} $start',
      if (end.isNotEmpty) '${LangKeys.toKey.tr()} $end',
    ].join(' ');
  }
}
