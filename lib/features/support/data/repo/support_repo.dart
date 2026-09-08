import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/support/data/datasources/remote/api/support_api_service.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_response_model.dart';

/// All data operations of the support feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a clean server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
/// The connection check and error mapping live in [_guard].
class SupportRepo {
  final SupportApiService _supportApiService = SupportApiService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _supportApiService.cancelRequests();

  /// Creates a support ticket from the user's complaint and returns the
  /// created ticket (the response's `data.ticket` object).
  Future<Either<Failure, ComplaintResponseModel>> submitComplaint({
    required ComplaintRequestModel complaint,
  }) {
    return _guard(
      () => _supportApiService.submitComplaint(complaint: complaint),
      (Map<String, dynamic> data) => ComplaintResponseModel.fromJson(
        data['ticket'] as Map<String, dynamic>?,
      ),
    );
  }

  /// Shared request envelope: connection check, non-2xx handling, and
  /// Dio/exception mapping, so each method only describes its own [parse].
  Future<Either<Failure, T>> _guard<T>(
    Future<Response> Function() request,
    T Function(Map<String, dynamic> data) parse,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await request();
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final int statusCode = response.statusCode ?? 0;
      if (statusCode != 200 && statusCode != 201) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return Right(parse(body['data'] as Map<String, dynamic>));
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (_) {
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }
}
