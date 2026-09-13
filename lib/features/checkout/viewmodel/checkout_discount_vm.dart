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
  (Ref ref) => CheckoutDiscountViewModel(),
);

class CheckoutDiscountViewModel {
  final CheckoutRepo _repo = CheckoutRepo();

  /// Applies coupon [code] for [vendorId] via the stateless calculator and
  /// forwards the result. The draft is intentionally untouched — the applied
  /// discount is owned by `appliedDiscountsProvider`, and the caller inspects
  /// [VendorDiscountApplicationModel.applied] to tell an accepted code from a
  /// rejected one.
  Future<Either<Failure, VendorDiscountApplicationModel>> applyCoupon({
    required int vendorId,
    required String code,
  }) => _repo.applyCoupon(vendorId: vendorId, code: code);

  /// Applies purchase-voucher [code] for [vendorId]. Same semantics as
  /// [applyCoupon].
  Future<Either<Failure, VendorDiscountApplicationModel>> applyPurchaseVoucher({
    required int vendorId,
    required String code,
  }) => _repo.applyPurchaseVoucher(vendorId: vendorId, code: code);
}
