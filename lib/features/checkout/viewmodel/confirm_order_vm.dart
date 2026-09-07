import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

/// Single task: confirm a draft order group — the final checkout step.
///
/// Unlike `checkoutProvider`, nothing is requested when the provider is first
/// watched: confirming is a user action, so the notifier starts idle
/// (`AsyncValue.data(<OrderModel>[])`) and the screen triggers it with
/// `ref.read(confirmOrderProvider.notifier).confirmOrder(...)`, then renders
/// the resulting [AsyncValue] (loading → data/error). On success the data is
/// the list of orders the server created, which the confirmation screen shows.
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

  /// Confirms the draft group identified by [orderGroupUuid] with the chosen
  /// [addressId] and [paymentMethod], plus the optional [driverTip], [notes]
  /// and [coupons].
  ///
  /// [coupons] arrives as the flat list the screen collects while the user
  /// applies codes; folding it into the `vendor id → code` map the request
  /// expects is this layer's job, so callers never assemble the map themselves.
  ///
  /// On success [state] becomes `data(orders)` and `null` is returned; on
  /// failure [state] becomes an error and the message is also returned so the
  /// caller can surface it — e.g. in a snackbar.
  Future<String?> confirmOrder({
    required String orderGroupUuid,
    required String idempotencyKey,
    int? addressId,
    String? paymentMethod,
    double? driverTip,
    String? notes,
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
      // Only coupons are sent to the backend at placement — vouchers are not
      // persisted there, so a voucher slot must not be posted as a coupon.
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
