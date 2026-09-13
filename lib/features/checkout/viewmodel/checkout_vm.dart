import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';

/// Single task: hold the draft order group the checkout screen renders,
/// regardless of which preview endpoint produced it — the all-stores
/// `checkout/cart/preview` ([checkout]) or the single-store
/// `checkout/vendor/{vendorId}/preview` ([checkoutForSingleStore]). Both flows
/// write the same `AsyncValue<CheckoutModel?>` state.
///
/// Discount application (coupons / purchase vouchers) is intentionally **not**
/// here — it lives in `checkoutDiscountProvider`.
///
/// Nothing is requested when the provider is first watched: drafting is a user
/// action fired from the **cart** screen — `checkout(vendorId: ...)` or
/// `checkoutForSingleStore(vendorId: ...)` — which only pushes the checkout
/// screen once the draft resolved, so the screen opens with its data already in
/// place.
///
/// State semantics on `AsyncValue<CheckoutModel?>`:
/// - `AsyncData(null)`           → idle, nothing drafted yet (initial),
/// - `AsyncLoading`              → a draft request is in flight,
/// - `AsyncData(CheckoutModel)`  → the current draft,
/// - `AsyncError`                → drafting failed; carries the message.
///
/// This provider is deliberately neither `autoDispose` nor a family: only one
/// draft is ever active, and its state has to survive the cart → checkout
/// navigation that happens between the request and the screen rendering it.
/// The single-store vs all-stores distinction is a parameter of the request
/// (`vendorId`), not of the provider.
final checkoutProvider =
    StateNotifierProvider<CheckoutViewModel, AsyncValue<CheckoutModel?>>(
      (Ref ref) => CheckoutViewModel(),
    );

class CheckoutViewModel extends StateNotifier<AsyncValue<CheckoutModel?>> {
  CheckoutViewModel() : super(const AsyncValue<CheckoutModel?>.data(null));

  final CheckoutRepo _repo = CheckoutRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<String?> checkout({int? vendorId}) async {
    state = const AsyncValue<CheckoutModel?>.loading();

    final result = await _repo.checkout(vendorId: vendorId);

    if (!mounted) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<CheckoutModel?>.error(
          failure.message,
          StackTrace.current,
        );
        return failure.message;
      },
      (CheckoutModel draft) {
        state = AsyncValue<CheckoutModel?>.data(draft);
        return null;
      },
    );
  }

  Future<String?> checkoutForSingleStore({required int vendorId}) async {
    state = const AsyncValue<CheckoutModel?>.loading();

    final result = await _repo.checkoutForSingleStore(vendorId: vendorId);

    if (!mounted) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<CheckoutModel?>.error(
          failure.message,
          StackTrace.current,
        );
        return failure.message;
      },
      (CheckoutModel draft) {
        state = AsyncValue<CheckoutModel?>.data(draft);
        return null;
      },
    );
  }
}