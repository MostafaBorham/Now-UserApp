import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/auth/data/datasources/remote/api/auth_api_service.dart';

/// All data operations of the auth feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class AuthRepo {
  final AuthApiService _authApiService = AuthApiService();

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
}
