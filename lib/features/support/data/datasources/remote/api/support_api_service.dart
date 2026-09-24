import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/support/data/datasources/remote/api/support_endpoints.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_request_model.dart';

/// Raw API calls for the support feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer), and the request body is the model's own
/// [ComplaintRequestModel.toJson].
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class SupportApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  /// Loads the about-section application information (used for its FAQ list)
  /// for the user scope.
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
}
