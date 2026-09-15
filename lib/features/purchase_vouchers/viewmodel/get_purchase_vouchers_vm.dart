import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/data/models/purchase_voucher_model.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/data/repo/purchase_voucher_repo.dart';









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
