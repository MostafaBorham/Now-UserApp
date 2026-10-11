import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/vendor_discount_application_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';

/// Owns discount application for checkout — coupons and purchase vouchers —
/// isolated from `checkoutProvider`, which holds only the checkout preview draft.
///
/// The two apply endpoints are stateless per-vendor calculators, so this view
/// model is stateless too: it holds no [StateNotifier] state of its own and just
/// forwards to the repo. The accepted discount is owned by
/// `appliedDiscountsProvider`; the caller inspects
/// [VendorDiscountApplicationModel.applied] to tell an accepted code from a
/// rejected one.
final checkoutDiscountProvider = Provider<CheckoutDiscountViewModel>(
  (Ref ref) => CheckoutDiscountViewModel(ref),
);

/// How many coupon / voucher applies are in flight. The confirm button waits
/// on it, so an order is never placed without the code the customer just
/// tapped. Lives as long as the confirm button watches it.
final discountApplyingProvider = StateProvider.autoDispose<int>(
  (Ref ref) => 0,
);

class CheckoutDiscountViewModel {
  CheckoutDiscountViewModel(this._ref);

  final Ref _ref;
  final CheckoutRepo _repo = CheckoutRepo();

  Future<T> _counted<T>(Future<T> Function() apply) async {
    final StateController<int> applying = _ref.read(
      discountApplyingProvider.notifier,
    );
    applying.state++;
    try {
      return await apply();
    } finally {
      // The screen may have closed meanwhile, disposing the counter.
      if (applying.mounted) applying.state--;
    }
  }

  /// Applies coupon [code] for [vendorId], delivered to [addressId], via the
  /// stateless calculator and forwards the result. The draft is intentionally
  /// untouched — the applied discount is owned by `appliedDiscountsProvider`,
  /// and the caller inspects [VendorDiscountApplicationModel.applied] to tell
  /// an accepted code from a rejected one.
  Future<Either<Failure, VendorDiscountApplicationModel>> applyCoupon({
    required int vendorId,
    required String code,
    int? addressId,
  }) => _counted(
    () => _repo.applyCoupon(
      vendorId: vendorId,
      code: code,
      addressId: addressId,
    ),
  );

  /// Applies purchase-voucher [code] for [vendorId]. Same semantics as
  /// [applyCoupon].
  Future<Either<Failure, VendorDiscountApplicationModel>> applyPurchaseVoucher({
    required int vendorId,
    required String code,
  }) => _counted(
    () => _repo.applyPurchaseVoucher(vendorId: vendorId, code: code),
  );
}
