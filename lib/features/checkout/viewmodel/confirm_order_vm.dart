import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_coupon_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';

/// Single task: confirm a draft order group — the final checkout step.
///
/// Unlike `checkoutProvider`, nothing is requested when the provider is first
/// watched: confirming is a user action, so the notifier starts idle
/// (`AsyncValue.data(null)`) and the screen triggers it with
/// `ref.read(confirmOrderProvider.notifier).confirmOrder(...)`, then renders
/// the resulting [AsyncValue] (loading → data/error).
final confirmOrderProvider = StateNotifierProvider.autoDispose<
    ConfirmOrderViewModel, AsyncValue<CheckoutModel?>>(
  (Ref ref) => ConfirmOrderViewModel(),
);

class ConfirmOrderViewModel extends StateNotifier<AsyncValue<CheckoutModel?>> {
  ConfirmOrderViewModel() : super(const AsyncValue<CheckoutModel?>.data(null));

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
  /// On success the confirmed group is swapped into [state] and `null` is
  /// returned; on failure [state] becomes an error and the message is also
  /// returned so the caller can surface it — e.g. in a snackbar.
  Future<String?> confirmOrder({
    required String orderGroupUuid,
    int? addressId,
    String? paymentMethod,
    double? driverTip,
    String? notes,
    List<AppliedCouponModel> coupons = const <AppliedCouponModel>[],
  }) async {
    state = const AsyncValue<CheckoutModel?>.loading();

    final result = await _repo.confirmOrder(
      orderGroupUuid: orderGroupUuid,
      addressId: addressId,
      paymentMethod: paymentMethod,
      driverTip: driverTip,
      notes: notes,
      coupons: <int, String>{
        for (final AppliedCouponModel coupon in coupons)
          coupon.vendorId: coupon.code,
      },
    );

    if (!mounted) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<CheckoutModel?>.error(
          failure.message,
          StackTrace.current,
        );
        return failure.message;
      },
      (CheckoutModel confirmed) {
        state = AsyncValue<CheckoutModel?>.data(confirmed);
        return null;
      },
    );
  }
}
