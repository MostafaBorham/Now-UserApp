import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/loggers/dio_logger.dart';
class DioFactory {
  DioFactory._();

  static const String _baseUrl = 'https://www.now-delivery.com';
  static const Duration _timeout = Duration(seconds: 15);

  static Dio? _dio;

  static Dio getDio() => _dio ??= _createAndConfigureDio();

  static Dio _createAndConfigureDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        responseType: ResponseType.json,
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(DioLogger.logger);

    return dio;
  }
}
