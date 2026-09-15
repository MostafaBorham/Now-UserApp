import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/welcome/data/datasources/remote/api/welcome_api_service.dart';






class WelcomeRepo {
  final WelcomeApiService _welcomeApiService = WelcomeApiService();
  final TokenCacheService _tokenCache = TokenCacheService();



  void cancelRequests() => _welcomeApiService.cancelRequests();





  Future<Either<Failure, String>> generateGuestToken() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _welcomeApiService.getGuestToken();

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 201) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final String guestToken = data['guest_token'] as String? ?? '';

      if (guestToken.isEmpty) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      await _tokenCache.saveGuestToken(guestToken);

      return Right(guestToken);
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
