import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/datasources/remote/api/profile_endpoints.dart';

/// Raw API calls for the personal_information feature.
///
/// Each method only performs the request and returns the Dio [Response];
/// parsing and error handling live in the repository. The Sanctum bearer token
/// is attached automatically by the shared `AuthTokenInterceptor`.
///
/// Cancellation is encapsulated here: every request carries the token of
/// [_canceller], and callers only see the plain [cancelRequests] method.
class ProfileApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  Future<Response> getProfile() {
    return _dio.get(ProfileEndpoints.profile, cancelToken: _canceller.token);
  }
}
