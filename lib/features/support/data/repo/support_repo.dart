import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/support/data/datasources/remote/api/support_api_service.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_response_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/rate_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/rate_response_model.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/faq_model.dart';

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

  /// Loads the support FAQs — parses only the `data.faqs` list of the
  /// about-section application information into [FaqModel]s.
  Future<Either<Failure, List<FaqModel>>> getSupportFaqs() {
    return _guard(
      () => _supportApiService.getSupportFaqs(),
      (Map<String, dynamic> data) =>
          ((data['faqs'] as List?) ?? const [])
              .map((e) => FaqModel.fromJson(e as Map<String, dynamic>?))
              .toList(),
    );
  }

  /// Rates a store (vendor) against an order and returns the created rating
  /// (the response's `data.rating` object).
  Future<Either<Failure, RateResponseModel>> rateStore({
    required RateRequestModel rate,
  }) {
    return _guard(
      () => _supportApiService.rateStore(rate: rate),
      (Map<String, dynamic> data) => RateResponseModel.fromJson(
        data['rating'] as Map<String, dynamic>?,
      ),
    );
  }

  /// Rates a delivery man against an order and returns the created rating
  /// (the response's `data.rating` object).
  Future<Either<Failure, RateResponseModel>> rateDeliveryMan({
    required RateRequestModel rate,
  }) {
    return _guard(
      () => _supportApiService.rateDeliveryMan(rate: rate),
      (Map<String, dynamic> data) => RateResponseModel.fromJson(
        data['rating'] as Map<String, dynamic>?,
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
      return readApiResponse(response).map(
        (Map<String, dynamic> body) =>
            parse(body['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );
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
