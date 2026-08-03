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

  /// Second singleton, dedicated to Google Places (New). Created lazily on
  /// first access, so apps that never open the address search never build it.
  static final Dio _placesDio = _createAndConfigurePlacesDio();

  /// Always returns the one shared [Dio] singleton.
  static Dio getDio() => _dio;

  /// Returns the shared [Dio] used for Google Places (New) requests.
  ///
  /// A separate instance is required for two reasons: Places lives on another
  /// host ([DioConstants.placesBaseUrl]), and it must **not** carry
  /// [AuthTokenInterceptor] — the user's bearer token has no business being
  /// sent to Google. Authentication here is the API key header instead.
  static Dio getPlacesDio() => _placesDio;

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

  static Dio _createAndConfigurePlacesDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: DioConstants.placesBaseUrl,
        connectTimeout: DioConstants.timeout,
        receiveTimeout: DioConstants.timeout,
        sendTimeout: DioConstants.timeout,
        responseType: ResponseType.json,
        headers: <String, String>{
          ...DioConstants.defaultHeaders,
          'X-Goog-Api-Key': DioConstants.googlePlacesApiKey,
        },
      ),
    );

    // No auth interceptor here — see [getPlacesDio].
    dio.interceptors.add(DioLogger.logger);

    return dio;
  }
}
