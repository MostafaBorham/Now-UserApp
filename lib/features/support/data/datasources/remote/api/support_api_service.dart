import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/support/data/datasources/remote/api/support_endpoints.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/rate_request_model.dart';










class SupportApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


  void cancelRequests() => _canceller.cancel();



  Future<Response> getSupportFaqs() {
    return _dio.get(
      SupportEndpoints.aboutInformation,
      queryParameters: SupportEndpoints.aboutInformationQuery(),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> submitComplaint({required ComplaintRequestModel complaint}) {
    return _dio.post(
      SupportEndpoints.supportTickets,
      data: complaint.toJson(),
      cancelToken: _canceller.token,
    );
  }



  Future<Response> rateStore({required RateRequestModel rate}) {
    return _dio.post(
      SupportEndpoints.ratings,
      data: rate.toJson(),
      cancelToken: _canceller.token,
    );
  }



  Future<Response> rateDeliveryMan({required RateRequestModel rate}) {
    return _dio.post(
      SupportEndpoints.ratings,
      data: rate.toJson(),
      cancelToken: _canceller.token,
    );
  }
}
