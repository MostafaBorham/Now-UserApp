import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';





class HeaderBannersApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  void cancelRequests() => _canceller.cancel();


  Future<Response> getHeaderBanners() {



    return _dio.get(
      'https://caliber-surgery-sanctuary.ngrok-free.dev/api/v1/banners',
      queryParameters: <String, dynamic>{'type': 'header_main_page'},
      cancelToken: _canceller.token,
    );
  }
}
