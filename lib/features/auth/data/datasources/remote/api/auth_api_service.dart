import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/auth/data/datasources/remote/api/auth_endpoints.dart';









class AuthApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


  void cancelRequests() => _canceller.cancel();

  Future<Response> requestOtp({required String phone}) {
    return _dio.post(
      AuthEndpoints.requestOtp,
      data: <String, dynamic>{'phone': phone},
      cancelToken: _canceller.token,
    );
  }




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




  Future<Response> logout() {
    return _dio.post(
      AuthEndpoints.logout,
      cancelToken: _canceller.token,
    );
  }
}
