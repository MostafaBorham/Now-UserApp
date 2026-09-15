import 'dart:async';

import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/dio/dio_constants.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/dio_logger.dart';

























class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor(this._dio);



  final Dio _dio;

  final TokenCacheService _tokenCache = TokenCacheService();


  static const String _refreshPath = '/api/v1/auth/user/refresh';



  static const String _retriedFlag = 'token_refresh_retried';




  late final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: DioConstants.baseUrl,
      connectTimeout: DioConstants.timeout,
      receiveTimeout: DioConstants.timeout,
      sendTimeout: DioConstants.timeout,
      responseType: ResponseType.json,
      headers: DioConstants.defaultHeaders,
    ),
  )..interceptors.add(DioLogger.logger);



  Future<bool>? _refreshGate;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions request = err.requestOptions;




    if (err.response?.statusCode != 401 ||
        request.extra[_retriedFlag] == true) {
      return handler.next(err);
    }





    if (request.data is FormData) {
      return handler.next(err);
    }




    final String currentAccess = _tokenCache.getAccessToken() ?? '';
    final String? sentAuth = request.headers['Authorization'] as String?;
    if (currentAccess.isNotEmpty && sentAuth != 'Bearer $currentAccess') {
      return _replay(request, handler, err);
    }


    final bool refreshed = await (_refreshGate ??= _refreshTokens());


    if (!refreshed) {
      return handler.next(err);
    }

    return _replay(request, handler, err);
  }




  Future<bool> _refreshTokens() async {
    try {
      final String refreshToken = _tokenCache.getRefreshToken() ?? '';
      if (refreshToken.isEmpty) return false;

      final Response response = await _refreshDio.post(
        _refreshPath,
        options: Options(
          headers: <String, String>{'Authorization': 'Bearer $refreshToken'},
        ),
      );

      final dynamic body = response.data;
      final Map<String, dynamic>? data = body is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>?
          : null;

      final String newAccess = data?['access_token'] as String? ?? '';
      final String newRefresh = data?['refresh_token'] as String? ?? '';
      if (newAccess.isEmpty || newRefresh.isEmpty) return false;

      await _tokenCache.saveUserTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _refreshGate = null;
    }
  }




  Future<void> _replay(
    RequestOptions request,
    ErrorInterceptorHandler handler,
    DioException originalError,
  ) async {
    request.extra[_retriedFlag] = true;


    request.headers['Authorization'] =
        'Bearer ${_tokenCache.getAccessToken() ?? ''}';

    try {
      final Response response = await _dio.fetch(request);

      handler.resolve(response);
    } on DioException catch (error) {


      handler.next(error);
    } catch (_) {
      handler.next(originalError);
    }
  }
}
