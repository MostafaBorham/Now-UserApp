import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/auth_token_interceptor.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/cart/data/datasources/remote/api/cart_endpoints.dart';

/// Raw API calls for the cart feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class CartApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  /// Fetches the current user's cart. Authenticated by a `Bearer` token
  /// passed in explicitly by the repository (read from the cache there). The
  /// `skipGuestToken` flag tells `AuthTokenInterceptor` not to attach the
  /// `X-Guest-Token` header, so this request carries the `Bearer` token only.
  Future<Response> getCart({required String token}) {
    return _dio.get(
      CartEndpoints.getCart,
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
