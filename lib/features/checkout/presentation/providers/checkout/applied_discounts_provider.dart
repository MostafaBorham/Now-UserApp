import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';

/// The coupons and purchase vouchers the user has successfully applied on the
/// checkout screen.
///
/// One slot per vendor: applying a code registers it here and the invoice
/// summary reads the whole list back to show the discount and reduce the total.
/// Because a vendor carries a single slot, applying a coupon replaces that
/// vendor's voucher and vice versa — this is what makes coupon/voucher mutual
/// exclusivity hold. Kept alive by the checkout screen watching it, and
/// disposed with the screen so a new checkout always starts empty.
final appliedDiscountsProvider = StateNotifierProvider.autoDispose<
    AppliedDiscountsNotifier, List<AppliedDiscountModel>>(
  (Ref ref) => AppliedDiscountsNotifier(),
);

class AppliedDiscountsNotifier
    extends StateNotifier<List<AppliedDiscountModel>> {
  AppliedDiscountsNotifier() : super(const <AppliedDiscountModel>[]);

  /// Registers [discount] and returns the discount it displaced for that
  /// vendor, or `null` if the slot was free. A vendor can only carry one
  /// discount at a time, so an earlier code for the same vendor is replaced
  /// rather than stacked — that replacement is what cancels a voucher when a
  /// coupon is applied and vice versa, and the returned slot is what lets the
  /// caller tell the user which code it just cancelled.
  ///
  /// A voucher also displaces any voucher on another vendor: the place request
  /// carries a single `voucher`, so a checkout holds one at most.
  AppliedDiscountModel? add(AppliedDiscountModel discount) {
    AppliedDiscountModel? replaced;
    final List<AppliedDiscountModel> others = <AppliedDiscountModel>[];
    for (final AppliedDiscountModel applied in state) {
      if (applied.vendorId == discount.vendorId) {
        replaced = applied;
      } else if (!(discount.isVoucher && applied.isVoucher)) {
        others.add(applied);
      }
    }
    state = <AppliedDiscountModel>[...others, discount];
    return replaced;
  }

  /// Drops the discount applied for [vendorId], if any.
  void remove(int vendorId) {
    state = state
        .where((AppliedDiscountModel applied) => applied.vendorId != vendorId)
        .toList();
  }

  /// Clears every applied discount.
  void clear() => state = const <AppliedDiscountModel>[];
}
