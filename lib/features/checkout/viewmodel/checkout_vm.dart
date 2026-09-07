import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/vendor_discount_application_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';

/// Single task: hold the draft order group the checkout screen renders.
///
/// Nothing is requested when the provider is first watched: drafting is a user
/// action fired from the **cart** screen — `checkout(vendorId: ...)` — which
/// only pushes the checkout screen once the draft resolved, so the screen opens
/// with its data already in place.
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

  /// Drafts an order group. A `null` [vendorId] drafts every store in the cart;
  /// a concrete [vendorId] drafts only that single store.
  ///
  /// On success the draft is swapped into [state] and `null` is returned; on
  /// failure [state] becomes an error and the message is also returned, so the
  /// caller can surface it — e.g. in a snackbar — and skip navigating.
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

  /// Applies coupon [code] for [vendorId] via the stateless calculator and
  /// forwards the result. The draft [state] is intentionally untouched — the
  /// applied discount is owned by `appliedDiscountsProvider`, and the caller
  /// inspects [VendorDiscountApplicationModel.applied] to tell an accepted code
  /// from a rejected one.
  Future<Either<Failure, VendorDiscountApplicationModel>> applyCoupon({
    required int vendorId,
    required String code,
  }) => _repo.applyCoupon(vendorId: vendorId, code: code);

  /// Applies purchase-voucher [code] for [vendorId]. Same semantics as
  /// [applyCoupon].
  Future<Either<Failure, VendorDiscountApplicationModel>> applyPurchaseVoucher({
    required int vendorId,
    required String code,
  }) => _repo.applyPurchaseVoucher(vendorId: vendorId, code: code);
}
