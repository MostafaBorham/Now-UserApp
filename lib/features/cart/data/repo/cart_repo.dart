import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/auth/data/datasources/local/cache/auth_cache_service.dart';
import 'package:nowdelivery_user_app/features/cart/data/datasources/remote/api/cart_api_service.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';

/// All data operations of the cart feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class CartRepo {
  final CartApiService _cartApiService = CartApiService();
  final AuthCacheService _authCacheService = AuthCacheService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _cartApiService.cancelRequests();

  /// Fetches the current user's cart together with its pricing estimate.
  ///
  /// Authenticates with the cached token (as a `Bearer` header), read here
  /// through [AuthCacheService] — the same pattern as `AuthRepo.logout`.
  Future<Either<Failure, CartModel>> getCart() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final String token = _authCacheService.getToken();

      final Response response = await _cartApiService.getCart(token: token);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (response.statusCode != 200 || !success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final CartModel cart =
          CartModel.fromJson(body['data'] as Map<String, dynamic>?);

      return Right(cart);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }
}
