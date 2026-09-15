import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';









final confirmOrderProvider =
    StateNotifierProvider.autoDispose<ConfirmOrderViewModel,
        AsyncValue<List<OrderModel>>>(
  (Ref ref) => ConfirmOrderViewModel(),
);

class ConfirmOrderViewModel
    extends StateNotifier<AsyncValue<List<OrderModel>>> {
  ConfirmOrderViewModel()
      : super(const AsyncValue<List<OrderModel>>.data(<OrderModel>[]));

  final CheckoutRepo _repo = CheckoutRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }












  Future<String?> confirmOrder({
    required String orderGroupUuid,
    required String idempotencyKey,
    int? addressId,
    String? paymentMethod,
    double? driverTip,
    String? notes,
    String? deliveryInstructions,
    List<AppliedDiscountModel> coupons = const <AppliedDiscountModel>[],
  }) async {
    state = const AsyncValue<List<OrderModel>>.loading();
    final result = await _repo.confirmOrder(
      orderGroupUuid: orderGroupUuid,
      idempotencyKey: idempotencyKey,
      addressId: addressId,
      paymentMethod: paymentMethod,
      driverTip: driverTip,
      notes: notes,
      deliveryInstructions: deliveryInstructions,


      coupons: <int, String>{
        for (final AppliedDiscountModel discount in coupons)
          if (!discount.isVoucher) discount.vendorId: discount.code,
      },
    );

    if (!mounted) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<List<OrderModel>>.error(
          failure.message,
          StackTrace.current,
        );
        return failure.message;
      },
      (List<OrderModel> orders) {
        state = AsyncValue<List<OrderModel>>.data(orders);
        return null;
      },
    );
  }
}
