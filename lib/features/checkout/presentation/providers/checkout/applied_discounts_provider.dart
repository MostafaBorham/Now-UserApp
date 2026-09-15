import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';










final appliedDiscountsProvider = StateNotifierProvider.autoDispose<
    AppliedDiscountsNotifier, List<AppliedDiscountModel>>(
  (Ref ref) => AppliedDiscountsNotifier(),
);

class AppliedDiscountsNotifier
    extends StateNotifier<List<AppliedDiscountModel>> {
  AppliedDiscountsNotifier() : super(const <AppliedDiscountModel>[]);



  void add(AppliedDiscountModel discount) {
    state = <AppliedDiscountModel>[
      ...state.where(
        (AppliedDiscountModel applied) => applied.vendorId != discount.vendorId,
      ),
      discount,
    ];
  }


  void remove(int vendorId) {
    state = state
        .where((AppliedDiscountModel applied) => applied.vendorId != vendorId)
        .toList();
  }


  void clear() => state = const <AppliedDiscountModel>[];
}
