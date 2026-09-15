import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/welcome/data/datasources/remote/api/welcome_endpoints.dart';









class WelcomeApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


  void cancelRequests() => _canceller.cancel();

  Future<Response> getGuestToken() {
    return _dio.post(
      WelcomeEndpoints.getGuestToken,
      cancelToken: _canceller.token,
    );
  }
}
