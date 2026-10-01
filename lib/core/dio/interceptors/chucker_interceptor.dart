import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';

/// Records every request for chucker_flutter's in-app network inspector, so QA
/// can see what the app sent and what came back.
///
/// QA builds only: [enabled] is a compile-time flag, on only in a build made
/// with `--dart-define=CHUCKER=true`. Never set it for a store build — each
/// record keeps the whole request, bearer and refresh tokens included, in plain
/// shared preferences, and the inspector lets anyone holding the phone share it.
///
/// Why this wraps [ChuckerDioInterceptor] instead of adding it directly: the
/// package keeps the request start time in a single field. On a Dio shared by
/// the whole app, every request in flight overwrites it, so overlapping calls
/// were saved with the wrong duration and the same timestamp — and that
/// timestamp is also the key chucker finds and deletes records by, so a toast's
/// "Details" could open a different request. One package instance per request
/// keeps each start time its own.
///
/// ponytail: chucker re-reads and rewrites its whole history (up to 100 records,
/// full bodies) on every response, and the response waits for it. Heavy screens
/// are slower in a QA build — don't judge performance on one. QA can lower "API
/// thresholds" in Chucker's settings; replace the package if that's not enough.
class ChuckerInterceptor extends Interceptor {
  static const bool enabled = bool.fromEnvironment('CHUCKER');

  static final Expando<ChuckerDioInterceptor> _byRequest =
      Expando<ChuckerDioInterceptor>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final ChuckerDioInterceptor chucker = ChuckerDioInterceptor();
    _byRequest[options] = chucker;
    chucker.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final ChuckerDioInterceptor? chucker = _byRequest[response.requestOptions];
    if (chucker == null) return handler.next(response);
    chucker.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ChuckerDioInterceptor? chucker = _byRequest[err.requestOptions];
    if (chucker == null) return handler.next(err);
    chucker.onError(err, handler);
  }
}
