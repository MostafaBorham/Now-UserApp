import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
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

      return readApiResponse(response, requireSuccessFlag: true).map(
        (_) => phone,
      );
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

      // `await` matters: the token writes below throw CacheException, and
      // returning the future unawaited would leave the try block before they
      // run, so the `on CacheException` arm would never see it.
      return await readApiResponse(response, requireSuccessFlag: true).fold(
        (Failure failure) async => Left<Failure, UserModel>(failure),
        (Map<String, dynamic> body) async {
          final Map<String, dynamic> data =
              body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
          final String accessToken = data['access_token'] as String? ?? '';
          final String refreshToken = data['refresh_token'] as String? ?? '';

          if (accessToken.isEmpty) {
            return Left<Failure, UserModel>(
              Failure(ApiErrorHandler.extractErrorMessage(body)),
            );
          }

          // Logging in as a user overrides any guest session: save the access +
          // refresh pair and drop the guest token so the interceptor stops
          // sending `X-Guest-Token`.
          await _tokenCache.saveUserTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
          await _tokenCache.clearGuestToken();

          return Right<Failure, UserModel>(
            UserModel.fromMap(
              data['user'] as Map<String, dynamic>? ?? <String, dynamic>{},
            ),
          );
        },
      );
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

  /// Logs the user out. **Always succeeds locally.**
  ///
  /// Telling the server is best-effort: it is attempted, and whatever it
  /// answers — a timeout, a 500, a 401 because the token had already expired,
  /// or no connection at all — the cached session is cleared and `unit` is
  /// returned.
  ///
  /// This used to gate on connectivity and clear the tokens only on a 2xx,
  /// which meant a failed request left the user fully signed in after they had
  /// asked to leave. On a shared device that is the wrong way to fail, and an
  /// expired token — the most common reason the call fails — is precisely when
  /// the local session most needs to go.
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _authApiService.logout();
    } catch (_) {
      // Deliberately ignored: the local session goes either way.
    }

    try {
      await _tokenCache.clearUserTokens();
    } on CacheException catch (exception) {
      return Left(Failure(exception.message));
    }

    return const Right(unit);
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
