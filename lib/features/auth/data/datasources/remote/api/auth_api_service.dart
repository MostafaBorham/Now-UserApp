import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/auth/data/datasources/remote/api/auth_endpoints.dart';

/// Raw API calls for the auth feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class AuthApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  Future<Response> requestOtp({required String phone}) {
    return _dio.post(
      AuthEndpoints.requestOtp,
      data: <String, dynamic>{'phone': phone},
      cancelToken: _canceller.token,
    );
  }
}
