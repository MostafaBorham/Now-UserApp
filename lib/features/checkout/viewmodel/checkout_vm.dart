import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';

/// Single task: draft an order group, keyed by an optional [vendorId].
///
/// - `null` vendorId → drafts every store in the cart.
/// - a concrete vendorId → drafts only that single store.
///
/// The draft starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(checkoutProvider(vendorId))` and render the [AsyncValue]
/// (pass `null` for the all-stores flow). Retry with
/// `ref.read(checkoutProvider(vendorId).notifier).checkout()`.
final checkoutProvider = StateNotifierProvider.autoDispose
    .family<CheckoutViewModel, AsyncValue<CheckoutModel>, int?>(
      (Ref ref, int? vendorId) => CheckoutViewModel(vendorId)..checkout(),
    );

class CheckoutViewModel extends StateNotifier<AsyncValue<CheckoutModel>> {
  CheckoutViewModel(this._vendorId) : super(const AsyncValue.loading());

  final int? _vendorId;
  final CheckoutRepo _repo = CheckoutRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> checkout() async {
    state = const AsyncValue.loading();

    final result = await _repo.checkout(vendorId: _vendorId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (CheckoutModel draft) => AsyncValue.data(draft),
    );
  }

  /// Applies coupon [code] for [vendorId] to the draft group identified by
  /// [orderGroupUuid]. The vendor→code map required by the repo is assembled
  /// here.
  ///
  /// On success the refreshed draft is swapped into [state] and `null` is
  /// returned. On failure [state] is left untouched (the current draft stays on
  /// screen) and the rejection reason is returned so the caller can surface it
  /// — e.g. in a snackbar.
  Future<String?> applyCoupons({
    required String orderGroupUuid,
    required int vendorId,
    required String code,
  }) async {
    final result = await _repo.applyCoupons(
      orderGroupUuid: orderGroupUuid,
      coupons: <int, String>{vendorId: code},
    );

    if (!mounted) return null;

    return result.fold(
      (Failure failure) => failure.message,
      (CheckoutModel draft) {
        state = AsyncValue.data(draft);
        return null;
      },
    );
  }
}