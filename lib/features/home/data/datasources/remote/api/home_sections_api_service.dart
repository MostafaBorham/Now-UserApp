import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';






class HomeSectionsApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  void cancelRequests() => _canceller.cancel();









  Future<Response> getHomeSections({
    required String platform,
    required String lang,
    double? lat,
    double? lng,
  }) {
    final bool hasLocation = lat != null && lng != null;
    return _dio.get(
      "https://caliber-surgery-sanctuary.ngrok-free.dev/api/v1/home-sections",
      queryParameters: <String, dynamic>{
        'platform': platform,
        'lang': lang,
        if (hasLocation) 'lat': lat,
        if (hasLocation) 'lng': lng,
      },
      cancelToken: _canceller.token,
    );
  }
}
