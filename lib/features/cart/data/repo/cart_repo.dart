import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/cart/data/datasources/remote/api/cart_api_service.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';

/// All data operations of the cart feature.
///
/// Every method returns `Either<Failure, CartModel>`: `Left` carries a
/// user-facing message (a [LangKeys] key or a raw server message — callers
/// apply `.tr()`, which leaves non-key strings untouched), `Right` carries the
/// cart as the server now holds it.
///
/// Every endpoint answers the same envelope — `{success, message, data: {cart}}`
/// — so the connection check, status handling, parsing and error mapping all
/// live in [_fetch] and each method is left with nothing but its own request.
/// Parsing runs inside that guard on purpose: a payload in an unexpected shape
/// then fails like a rejected request instead of throwing out of the repo and
/// reaching the shopper as a raw Dart error in place of their cart.
class CartRepo {
  /// Both collaborators are injectable so the repo can be exercised without a
  /// live [Dio] singleton or a real connectivity probe — [ConnectionChecker]
  /// reaches the network, which a unit test cannot do. Production callers keep
  /// using `CartRepo()` and get the real ones. Mirrors `AddressRepo`.
  CartRepo({CartApiService? api, Future<bool> Function()? isConnected})
    : _cartApiService = api ?? CartApiService(),
      _isConnected = isConnected ?? (() => ConnectionChecker.isConnected);

  final CartApiService _cartApiService;
  final Future<bool> Function() _isConnected;

  void cancelRequests() => _cartApiService.cancelRequests();

  Future<Either<Failure, CartModel>> getCart() =>
      _fetch(_cartApiService.getCart);

  Future<Either<Failure, CartModel>> deleteCartVendorItem(int vendorId) =>
      _fetch(() => _cartApiService.deleteCartVendorItem(vendorId));

  /// Sets this cart line to [quantity]; `0` removes the line, which is the only
  /// delete path a single line has. [cartItemId] picks which line of the product
  /// to change when it is in the cart as several variants.
  Future<Either<Failure, CartModel>> updateCartProductQuantity(
    int productId,
    int quantity, {
    int? cartItemId,
  }) => _fetch(
    () => _cartApiService.updateCartProductQuantity(
      productId,
      quantity,
      cartItemId: cartItemId,
    ),
  );

  Future<Either<Failure, CartModel>> addToCart(
    int productId,
    int quantity,
    Map<String, dynamic>? options,
  ) => _fetch(() => _cartApiService.addToCart(productId, quantity, options));

  /// Runs [request] and reads the cart out of the envelope it answers with.
  ///
  /// A 2xx carrying `success: true` is the only outcome that holds a cart;
  /// everything else is reported as a [Failure] with the server's own message.
  Future<Either<Failure, CartModel>> _fetch(
    Future<Response> Function() request,
  ) async {
    if (!await _isConnected()) {
      return const Left<Failure, CartModel>(
        Failure(LangKeys.noInternetConnectionKey),
      );
    }

    try {
      final Response response = await request();

      // Nothing is cast blindly: a body that is not an object is treated as a
      // failed response rather than throwing.
      final dynamic raw = response.data;
      final Map<String, dynamic> body = raw is Map<String, dynamic>
          ? raw
          : <String, dynamic>{};

      final int statusCode = response.statusCode ?? 0;
      final bool success = body['success'] as bool? ?? false;

      if (statusCode < 200 || statusCode >= 300 || !success) {
        return Left<Failure, CartModel>(
          Failure(ApiErrorHandler.extractErrorMessage(body)),
        );
      }

      // An empty cart often comes back as `data: []` rather than `data: {}`,
      // so this has to be a check and not a cast.
      final dynamic data = body['data'];

      return Right<Failure, CartModel>(
        CartModel.fromJson(data is Map<String, dynamic> ? data : null),
      );
    } on DioException catch (exception) {
      final Response<dynamic>? response = exception.response;

      // No response at all means we never reached the server (DNS, timeout,
      // connection dropped, request cancelled). That is a different failure
      // from one the server answered with, so it gets its own key rather than
      // `ApiErrorHandler`'s untranslated English default — which an Arabic user
      // would otherwise be shown verbatim.
      if (response == null) {
        return const Left<Failure, CartModel>(
          Failure(LangKeys.serverConnectionFailedKey),
        );
      }

      final dynamic data = response.data;
      return Left<Failure, CartModel>(
        Failure(
          ApiErrorHandler.extractErrorMessage(
            data is Map<String, dynamic> ? data : null,
          ),
        ),
      );
    } catch (_) {
      // Never surface a raw exception string: it ends up in a toast, or as the
      // cart screen's entire error state.
      return const Left<Failure, CartModel>(
        Failure(LangKeys.serverConnectionFailedKey),
      );
    }
  }
}
