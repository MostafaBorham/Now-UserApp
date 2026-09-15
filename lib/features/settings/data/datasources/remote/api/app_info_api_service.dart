import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/settings/data/datasources/remote/api/app_info_endpoints.dart';









class AppInfoApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


  void cancelRequests() => _canceller.cancel();

  Future<Response> getAppInfo() {
    return _dio.get(
      AppInfoEndpoints.getAppInfo,
      cancelToken: _canceller.token,
    );
  }
}
