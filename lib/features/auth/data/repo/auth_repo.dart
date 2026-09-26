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

  /// The backend's resend window (`otp.resend_after`). A fresh send carries no
  /// countdown of its own, so this is the wait before the next one.
  static const int _resendAfterSeconds = 60;

  /// Asks for a code for [phone]. Resolves the seconds to wait before the next
  /// resend — a code is on its way either way: a fresh one, or one sent so
  /// recently that the backend refused another (see [recentlySentRetryAfter]).
  Future<Either<Failure, int>> requestOtp({required String phone}) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _authApiService.requestOtp(phone: phone);

      return readApiResponse(
        response,
        requireSuccessFlag: true,
      ).map((_) => _resendAfterSeconds);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;

      final int? retryAfter = recentlySentRetryAfter(
        statusCode: exception.response?.statusCode,
        body: responseBody,
      );
      if (retryAfter != null) return Right(retryAfter);

      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (_) {
      // An exception's text is a Dart error, not a message for the customer.
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }

  /// The seconds left before another code may be requested, when a refused
  /// request means "a code was already sent" — otherwise null.
  ///
  /// The backend answers 429 for two unrelated reasons, and only one of them is
  /// good news:
  /// * the resend cooldown (`OtpRecentlyIssuedException`): a code went out
  ///   moments ago and is still valid, so the user belongs on the code screen.
  ///   It is the only response carrying `retry_after`;
  /// * the `throttle:auth.otp` limiter (5 per phone per 5 minutes, 10 per IP a
  ///   minute), carrying `retry_after_seconds`: nothing was sent, and verify
  ///   spends the same budget, so the user must see its message instead.
  static int? recentlySentRetryAfter({
    required int? statusCode,
    required Map<String, dynamic>? body,
  }) {
    if (statusCode != 429) return null;
    final num? retryAfter = num.tryParse('${body?['retry_after']}');
    if (retryAfter == null) return null;
    return retryAfter < 0 ? 0 : retryAfter.toInt();
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
    } catch (_) {
      // An exception's text is a Dart error, not a message for the customer.
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
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
    } catch (_) {
      // An exception's text is a Dart error, not a message for the customer.
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }
}
