import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_constants.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/auth_token_interceptor.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/dio_logger.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/token_refresh_interceptor.dart';

class DioFactory {
  DioFactory._();




  static final Dio _dio = _createAndConfigureDio();



  static final Dio _placesDio = _createAndConfigurePlacesDio();


  static Dio getDio() => _dio;







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





    dio.interceptors.add(AuthTokenInterceptor());
    dio.interceptors.add(DioLogger.logger);
    dio.interceptors.add(TokenRefreshInterceptor(dio));

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


    dio.interceptors.add(DioLogger.logger);

    return dio;
  }
}
