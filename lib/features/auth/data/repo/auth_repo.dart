import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/auth/data/datasources/local/cache/auth_cache_service.dart';
import 'package:nowdelivery_user_app/features/auth/data/datasources/remote/api/auth_api_service.dart';
import 'package:nowdelivery_user_app/features/auth/data/models/user_model.dart';

/// All data operations of the auth feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class AuthRepo {
  final AuthApiService _authApiService = AuthApiService();
  final AuthCacheService _authCacheService = AuthCacheService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _authApiService.cancelRequests();

  /// Requests an OTP to be sent to [phone].
  ///
  /// `Right` carries the phone the OTP was sent to (only when the server
  /// reports `success: true`); anything else is a `Left` carrying the
  /// server's `message`.
  Future<Either<Failure, String>> requestOtp({required String phone}) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _authApiService.requestOtp(phone: phone);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (!success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return Right(phone);
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

  /// Verifies the OTP [code] sent to [phone] and logs the user in.
  ///
  /// The request is authenticated by the cached guest token, attached
  /// automatically by `AuthTokenInterceptor`; on success the cached token is
  /// replaced with the auth token from the response (`isGuest: false`).
  /// `Right` carries the logged-in user (only when the server reports
  /// `success: true` and the token has been saved to the cache); anything
  /// else is a `Left` carrying the error message.
  Future<Either<Failure, UserModel>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _authApiService.verifyOtp(
        phone: phone,
        code: code,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (!success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final String authToken = data['token'] as String? ?? '';

      if (authToken.isEmpty) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      await _authCacheService.saveToken(token: authToken, isGuest: false);

      final UserModel user = UserModel.fromMap(
        data['user'] as Map<String, dynamic>,
      );
      return Right(user);
    } on CacheException catch (exception) {
      return Left(Failure(exception.message));
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

  /// Logs the current user out.
  ///
  /// Authenticates with the cached token (as a `Bearer` header) and, only when
  /// the server reports `success: true`, clears the cached session so the app
  /// falls back to a logged-out state. `Right(unit)` means the user is fully
  /// logged out; anything else is a `Left` carrying the error message.
  Future<Either<Failure, Unit>> logout() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final String token = _authCacheService.getToken();

      final Response response = await _authApiService.logout(token: token);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (!success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      await _authCacheService.clearToken();

      return const Right(unit);
    } on CacheException catch (exception) {
      return Left(Failure(exception.message));
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