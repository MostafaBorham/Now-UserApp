import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_constants.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/auth_token_interceptor.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/dio_logger.dart';

class DioFactory {
  DioFactory._();

  /// Single, immutable Dio instance. As a `static final` it is created lazily
  /// on first access and exactly once, so the same instance is reused for the
  /// whole app lifetime.
  static final Dio _dio = _createAndConfigureDio();

  /// Always returns the one shared [Dio] singleton.
  static Dio getDio() => _dio;

  static Dio _createAndConfigureDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: DioConstants.baseUrl,
        connectTimeout: DioConstants.timeout,
        receiveTimeout: DioConstants.timeout,
        sendTimeout: DioConstants.timeout,
        responseType: ResponseType.json,
        headers: DioConstants.defaultHeaders,
      ),
    );

    // Order matters: attach the token first so the logger prints the final
    // outgoing headers.
    dio.interceptors.add(AuthTokenInterceptor());
    dio.interceptors.add(DioLogger.logger);

    return dio;
  }
}
