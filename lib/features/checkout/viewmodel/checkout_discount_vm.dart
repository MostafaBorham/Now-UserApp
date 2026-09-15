import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/vendor_discount_application_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';










final checkoutDiscountProvider = Provider<CheckoutDiscountViewModel>(
  (Ref ref) => CheckoutDiscountViewModel(),
);

class CheckoutDiscountViewModel {
  final CheckoutRepo _repo = CheckoutRepo();






  Future<Either<Failure, VendorDiscountApplicationModel>> applyCoupon({
    required int vendorId,
    required String code,
  }) => _repo.applyCoupon(vendorId: vendorId, code: code);



  Future<Either<Failure, VendorDiscountApplicationModel>> applyPurchaseVoucher({
    required int vendorId,
    required String code,
  }) => _repo.applyPurchaseVoucher(vendorId: vendorId, code: code);
}
