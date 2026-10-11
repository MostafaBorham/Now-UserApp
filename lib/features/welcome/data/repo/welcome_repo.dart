import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/welcome/data/datasources/remote/api/welcome_api_service.dart';

/// All data operations of the welcome feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class WelcomeRepo {
  final WelcomeApiService _welcomeApiService = WelcomeApiService();
  final TokenCacheService _tokenCache = TokenCacheService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _welcomeApiService.cancelRequests();

  /// Requests a guest token and persists it locally.
  ///
  /// `Right` is returned only after the token has been saved to the cache;
  /// a failed save is a `Left` just like a failed request.
  Future<Either<Failure, String>> generateGuestToken() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _welcomeApiService.getGuestToken();

      // `await`: saveGuestToken throws CacheException, and an unawaited future
      // would escape the try block before the `on CacheException` arm could see
      // it. The status is no longer pinned to exactly 201 — any 2xx is a
      // success, so a backend that answers 200 does not break guest onboarding.
      return await readApiResponse(response, requireSuccessFlag: true).fold(
        (Failure failure) async => Left<Failure, String>(failure),
        (Map<String, dynamic> body) async {
          final Map<String, dynamic> data = responseData(body);
          final String guestToken = data['guest_token'] as String? ?? '';

          if (guestToken.isEmpty) {
            return Left<Failure, String>(
              Failure(ApiErrorHandler.extractErrorMessage(body)),
            );
          }

          await _tokenCache.saveGuestToken(guestToken);

          return Right<Failure, String>(guestToken);
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
}
