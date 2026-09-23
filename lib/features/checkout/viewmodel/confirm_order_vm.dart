import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/utils/idempotency_key.dart';
import 'package:nowdelivery_user_app/features/checkout/data/datasources/remote/api/checkout_endpoints.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

/// Single task: place the order — the final checkout step.
///
/// Unlike `checkoutProvider`, nothing is requested when the provider is first
/// watched: placing is a user action, so the notifier starts idle
/// (`AsyncValue.data(<OrderModel>[])`) and the screen triggers it with
/// `ref.read(confirmOrderProvider.notifier).confirmOrder(...)`, then renders
/// the resulting [AsyncValue] (loading → data/error). On success the data is
/// the list of orders the server created, which the confirmation screen shows.
///
/// `autoDispose`, and watched by the confirm button, so it lives exactly as
/// long as the checkout screen — which is also the lifetime of its
/// idempotency key.
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

  /// Reused across retries of an unchanged order (a retry after a lost
  /// response then replays instead of placing twice), rotated when the order
  /// changes or after it was placed.
  final IdempotencyKey _idempotencyKey = IdempotencyKey();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  /// Places the order for [vendorId] (`null` = every store in the cart) with
  /// the chosen address, payment method, tip, instructions and [discounts] —
  /// the coupons and voucher the user applied on the checkout screen.
  ///
  /// On success [state] becomes `data(orders)` and `null` is returned; on
  /// failure [state] becomes an error and the message is also returned so the
  /// caller can surface it — e.g. in a snackbar.
  Future<String?> confirmOrder({
    int? vendorId,
    required int addressId,
    required String paymentMethod,
    int? paymentMethodId,
    double driverTip = 0,
    String deliveryInstructions = '',
    List<AppliedDiscountModel> discounts = const <AppliedDiscountModel>[],
  }) async {
    final Map<String, dynamic> body = CheckoutEndpoints.placeBody(
      vendorId: vendorId,
      addressId: addressId,
      paymentMethod: paymentMethod,
      paymentMethodId: paymentMethodId,
      driverTip: driverTip,
      deliveryInstructions: deliveryInstructions,
      discounts: discounts,
    );
    // The body is exactly what the server checks the key against, so it is
    // the fingerprint too — no hand-kept list of fields to drift out of sync.
    final String idempotencyKey = _idempotencyKey.forRequest(jsonEncode(body));

    state = const AsyncValue<List<OrderModel>>.loading();
    final result = await _repo.placeOrder(
      vendorId: vendorId,
      idempotencyKey: idempotencyKey,
      body: body,
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
        // Placed: any later order is new, not a replay of this one.
        _idempotencyKey.markConsumed();
        state = AsyncValue<List<OrderModel>>.data(orders);
        return null;
      },
    );
  }
}
