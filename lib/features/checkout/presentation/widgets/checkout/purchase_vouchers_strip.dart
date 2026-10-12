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
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';

/// The purchase-vouchers strip on the checkout screen.
///
/// Fetches vouchers for the checkout's vendor(s) and renders each as the shared
/// [VoucherTicket]. A voucher applicable to this checkout is tappable
/// (tapping applies it to its vendor); others are dimmed. The applied voucher
/// gets a highlight border. Hidden entirely while loading, on error, or when
/// there are no vouchers.
///
/// While an apply request is in flight the tapped ticket shows a blocking
/// progress overlay and every other ticket is disabled, so only one voucher can
/// be applied at a time. On failure nothing is applied (the previous selection
/// stands) and an error toast is shown; on success the voucher stays selected.
class PurchaseVouchersStrip extends ConsumerStatefulWidget {
  const PurchaseVouchersStrip({super.key});

  @override
  ConsumerState<PurchaseVouchersStrip> createState() =>
      _PurchaseVouchersStripState();
}

class _PurchaseVouchersStripState extends ConsumerState<PurchaseVouchersStrip> {
  /// Identifies the voucher whose apply request is currently in flight
  /// (`'<vendorId>:<code>'`), or `null` when none is. Drives the per-ticket
  /// progress overlay and locks every other ticket until the request settles.
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

    // One apply may be in flight across the whole strip; while it is, every
    // ticket is locked so a second voucher can't be applied concurrently.
    final bool isApplying = _applyingKey != null;

    // Carries its own gap below, so a checkout with no vouchers gets none
    // (QA-030 S3): the screen groups it with the invoice.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: VoucherTicketsList(
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

          // Non-applicable tickets are never tappable; while an apply is in
          // flight every other ticket is locked too.
          final bool tappable = applicable && !isApplying;

          // Clip the overlay to the ticket's rounded corners so the progress
          // barrier doesn't paint white squares over the transparent corners.
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
    PurchaseVoucherModel voucher,
    int vendorId,
    bool selected,
  ) async {
    // Tapping the already-applied voucher unselects it, leaving the vendor with
    // no discount — the user can proceed without a voucher. This is a local
    // toggle, so no request and no loading state.
    if (selected) {
      ref.read(appliedDiscountsProvider.notifier).remove(vendorId);
      return;
    }

    // Lock the strip on this ticket while the calculator runs.
    setState(() => _applyingKey = _voucherKey(vendorId, voucher.code));

    final result = await ref
        .read(checkoutDiscountProvider)
        .applyPurchaseVoucher(vendorId: vendorId, code: voucher.code);

    if (!mounted) return;

    // Clearing the key first hands control back to the user regardless of the
    // outcome; the applied discount itself is only touched on success.
    setState(() => _applyingKey = null);

    result.fold(
      // Voucher rejection reasons come back as raw untranslated keys, so never
      // surface the server text — show a generic message. A request that never
      // reached the server says so instead of blaming the voucher (QA-003 A5).
      // Nothing was applied, so the previous selection (if any) still stands.
      (Failure failure) => AppToast.showError(
        context,
        _isTransport(failure)
            ? failure.message.tr()
            : LangKeys.voucherApplyFailedKey.tr(),
      ),
      (model) {
        if (!model.applied) {
          AppToast.showError(context, LangKeys.voucherApplyFailedKey.tr());
          return;
        }
        final AppliedDiscountModel? replaced = ref
            .read(appliedDiscountsProvider.notifier)
            .add(
              AppliedDiscountModel(
                vendorId: vendorId,
                code: voucher.code,
                isVoucher: true,
              ),
            );
        // The vendor's single slot means this voucher just cancelled a coupon
        // applied to the same store — the coupon chip reverts to an empty
        // field, so say why.
        if (replaced != null && !replaced.isVoucher) {
          AppToast.showSuccess(
            context,
            LangKeys.couponReplacedByVoucherKey.tr(),
          );
        }
      },
    );
  }

  static bool _isTransport(Failure failure) =>
      failure.message == LangKeys.noInternetConnectionKey ||
      failure.message == LangKeys.serverConnectionFailedKey;

  /// The bare discount amount (no `%`/currency — [VoucherTicket] adds the unit).
  String _discountText(PurchaseVoucherModel voucher) {
    final double v = voucher.discountValue;
    return v % 1 == 0 ? v.toInt().toString() : v.toString();
  }

  /// Validity window as "from {startsAt} to {expiresAt}", with each side
  /// dropped when its date is missing.
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
