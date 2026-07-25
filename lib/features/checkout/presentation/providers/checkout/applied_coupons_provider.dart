import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_coupon_model.dart';

/// The coupons the user has successfully applied on the checkout screen.
///
/// Each discount field registers its code here once the server accepted it, and
/// the confirm-order request reads the whole list back. Kept alive by the
/// checkout screen watching it, and disposed with the screen so a new checkout
/// always starts with an empty list.
final appliedCouponsProvider = StateNotifierProvider.autoDispose<
    AppliedCouponsNotifier, List<AppliedCouponModel>>(
  (Ref ref) => AppliedCouponsNotifier(),
);

class AppliedCouponsNotifier extends StateNotifier<List<AppliedCouponModel>> {
  AppliedCouponsNotifier() : super(const <AppliedCouponModel>[]);

  /// Registers [coupon]. A vendor can only carry one coupon at a time, so an
  /// earlier code for the same vendor is replaced rather than stacked.
  void add(AppliedCouponModel coupon) {
    state = <AppliedCouponModel>[
      ...state.where(
        (AppliedCouponModel applied) => applied.vendorId != coupon.vendorId,
      ),
      coupon,
    ];
  }

  /// Drops the coupon applied for [vendorId], if any.
  void remove(int vendorId) {
    state = state
        .where((AppliedCouponModel applied) => applied.vendorId != vendorId)
        .toList();
  }

  /// Clears every applied coupon.
  void clear() => state = const <AppliedCouponModel>[];
}
