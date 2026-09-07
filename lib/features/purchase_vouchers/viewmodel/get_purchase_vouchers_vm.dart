import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/data/models/purchase_voucher_model.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/data/repo/purchase_voucher_repo.dart';

/// First page of purchase vouchers for the checkout strip, keyed by the
/// checkout's store id (`null` = all-stores checkout, fetch everything).
///
/// Any failure folds to an empty list so the strip simply hides — the vouchers
/// are an optional affordance, not a blocking part of checkout.
///
/// ponytail: first page only (per_page 10); add paging if a store ever ships
/// more vouchers than that.
final getPurchaseVouchersProvider = FutureProvider.autoDispose
    .family<List<PurchaseVoucherModel>, int?>((Ref ref, int? storeId) async {
      final result = await PurchaseVoucherRepo().getPurchaseVouchers(
        storeId: storeId,
      );
      return result.fold(
        (_) => const <PurchaseVoucherModel>[],
        (page) => page.data,
      );
    });
