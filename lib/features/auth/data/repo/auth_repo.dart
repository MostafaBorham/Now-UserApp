import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/auth/data/datasources/remote/api/auth_api_service.dart';
import 'package:nowdelivery_user_app/features/auth/data/models/user_model.dart';

class AuthRepo {
  final AuthApiService _authApiService = AuthApiService();
  final TokenCacheService _tokenCache = TokenCacheService();

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
      final String accessToken = data['access_token'] as String? ?? '';
      final String refreshToken = data['refresh_token'] as String? ?? '';

      if (accessToken.isEmpty) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      // Logging in as a user overrides any guest session: save the access +
      // refresh pair and drop the guest token so the interceptor stops sending
      // `X-Guest-Token`.
      await _tokenCache.saveUserTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await _tokenCache.clearGuestToken();

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

  Future<Either<Failure, Unit>> logout() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _authApiService.logout();

      final int statusCode = response.statusCode ?? 0;

      if (statusCode != 200 && statusCode != 204) {
        final String? statusMessage = response.statusMessage?.trim();
        return Left(
          Failure(
            statusMessage != null && statusMessage.isNotEmpty
                ? statusMessage
                : ApiErrorHandler.extractErrorMessage(null),
          ),
        );
      }

      await _tokenCache.clearUserTokens();

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
      return Right(
        _tokenCache.hasAccessToken ? SessionType.user : SessionType.guest,
      );
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }
}
