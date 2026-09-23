import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/datasources/remote/api/checkout_endpoints.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';

final checkoutProvider =
    StateNotifierProvider<CheckoutViewModel, AsyncValue<CheckoutModel?>>(
      (Ref ref) => CheckoutViewModel(),
    );

/// The checkout's pricing, straight from the server.
///
/// [checkout] opens a checkout; [reprice] and [refresh] then price it again as
/// the customer changes what the server charges for — address, tip, coupons,
/// voucher — so the invoice shows what placing the order will charge. A
/// re-price keeps the loaded checkout in state (loading, then data or error,
/// each carrying the previous value), so the screen never drops to its shimmer.
class CheckoutViewModel extends StateNotifier<AsyncValue<CheckoutModel?>> {
  CheckoutViewModel() : super(const AsyncValue<CheckoutModel?>.data(null));

  final CheckoutRepo _repo = CheckoutRepo();

  /// The store being checked out (`null` = the whole cart), fixed by
  /// [checkout] so every re-price asks the same endpoint.
  int? _vendorId;

  /// The choices the latest request was priced with.
  Map<String, dynamic> _body = const <String, dynamic>{};

  /// Counts requests, so an answer that lost the race to a newer one is
  /// dropped rather than rolling the invoice back.
  int _request = 0;

  /// Coalesces a burst of changes — the tip counter's taps — into one request:
  /// every preview shares the per-user checkout rate limit (30 a minute) with
  /// apply, place and cancel.
  Timer? _debounce;

  static const Duration _debounceDelay = Duration(milliseconds: 400);

  @override
  void dispose() {
    _debounce?.cancel();
    _repo.cancelRequests();
    super.dispose();
  }

  /// Opens the checkout of [vendorId] — `null` for every store in the cart —
  /// priced for [addressId].
  Future<String?> checkout({int? vendorId, int? addressId}) {
    _debounce?.cancel();
    _vendorId = vendorId;
    _body = CheckoutEndpoints.pricingBody(
      vendorId: vendorId,
      addressId: addressId,
    );
    state = const AsyncValue<CheckoutModel?>.loading();
    return _fetch();
  }

  /// Prices the open checkout again with the customer's current choices. A
  /// no-op when they price the same as the last request.
  void reprice({
    int? addressId,
    double driverTip = 0,
    List<AppliedDiscountModel> discounts = const <AppliedDiscountModel>[],
  }) {
    final Map<String, dynamic> body = CheckoutEndpoints.pricingBody(
      vendorId: _vendorId,
      addressId: addressId,
      driverTip: driverTip,
      discounts: discounts,
    );
    if (jsonEncode(body) == jsonEncode(_body)) return;
    _body = body;
    refresh();
  }

  /// Prices the open checkout again with unchanged choices — for what the
  /// preview carries besides the price, like the saved cards after one is
  /// added.
  void refresh() {
    _debounce?.cancel();
    // Loading from now, not from when the request leaves, so confirm is held
    // back through the debounce too — never placed against a stale total.
    state = const AsyncValue<CheckoutModel?>.loading().copyWithPrevious(state);
    _debounce = Timer(_debounceDelay, _fetch);
  }

  Future<String?> _fetch() async {
    final int request = ++_request;
    final result = await _repo.preview(vendorId: _vendorId, body: _body);

    if (!mounted || request != _request) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<CheckoutModel?>.error(
          failure.message,
          StackTrace.current,
        ).copyWithPrevious(state);
        return failure.message;
      },
      (CheckoutModel checkout) {
        state = AsyncValue<CheckoutModel?>.data(checkout);
        return null;
      },
    );
  }
}
