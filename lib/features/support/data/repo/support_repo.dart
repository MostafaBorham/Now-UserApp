import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/support/data/datasources/remote/api/support_api_service.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_response_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/rate_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/rate_response_model.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/faq_model.dart';







class SupportRepo {
  final SupportApiService _supportApiService = SupportApiService();



  void cancelRequests() => _supportApiService.cancelRequests();



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



  Future<Either<Failure, List<FaqModel>>> getSupportFaqs() {
    return _guard(
      () => _supportApiService.getSupportFaqs(),
      (Map<String, dynamic> data) =>
          ((data['faqs'] as List?) ?? const [])
              .map((e) => FaqModel.fromJson(e as Map<String, dynamic>?))
              .toList(),
    );
  }



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
