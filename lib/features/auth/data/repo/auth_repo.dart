import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/auth/data/datasources/local/cache/auth_cache_service.dart';
import 'package:nowdelivery_user_app/features/auth/data/datasources/remote/api/auth_api_service.dart';
import 'package:nowdelivery_user_app/features/auth/data/models/user_model.dart';

class AuthRepo {
  final AuthApiService _authApiService = AuthApiService();
  final AuthCacheService _authCacheService = AuthCacheService();


  void cancelRequests() => _authApiService.cancelRequests();

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
      final String authToken = data['access_token'] as String? ?? '';

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
  /// Authentication is applied automatically by `AuthTokenInterceptor` (the
  /// logged-in user's `Bearer` token from the cached session). Only when the
  /// server reports `success: true` is the cached session cleared, so the app
  /// falls back to a logged-out state. `Right(unit)` means the user is fully
  /// logged out; anything else is a `Left` carrying the error message.
  Future<Either<Failure, Unit>> logout() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _authApiService.logout();

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

  Future<Either<Failure, SessionType>> getSessionType() async {
    try {
      final Map<String, dynamic> session = _authCacheService.getSession();

      final bool isGuest = session[CacheKeys.isGuest] as bool? ?? true;

      if (isGuest) {
        return const Right(SessionType.guest);
      }

      return const Right(SessionType.user);
    } on CacheException catch (exception) {
      return Left(Failure(exception.message));
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }
}