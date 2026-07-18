import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/auth_token_interceptor.dart';
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

  /// Verifies the OTP [code] sent to [phone]. The caller's guest session is
  /// identified by the `X-Guest-Token` header, attached automatically from
  /// the cache by `AuthTokenInterceptor` — no token is passed here.
  Future<Response> verifyOtp({
    required String phone,
    required String code,
  }) {
    return _dio.post(
      AuthEndpoints.verifyOtp,
      data: <String, dynamic>{'phone': phone, 'code': code},
      cancelToken: _canceller.token,
    );
  }

  /// Logs the current user out. Authenticated by a `Bearer` token passed in
  /// explicitly by the repository (read from the cache there). The
  /// `skipGuestToken` flag tells `AuthTokenInterceptor` not to attach the
  /// `X-Guest-Token` header, so this request carries the `Bearer` token only.
  Future<Response> logout({required String token}) {
    return _dio.post(
      AuthEndpoints.logout,
      cancelToken: _canceller.token,
      options: Options(
        headers: <String, dynamic>{'Authorization': 'Bearer $token'},
        extra: <String, dynamic>{
          AuthTokenInterceptor.skipGuestTokenKey: true,
        },
      ),
    );
  }
}
