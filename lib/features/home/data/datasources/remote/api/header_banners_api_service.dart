import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';

/// Raw API call for the home header banner carousel.
///
/// Only performs the request and returns the Dio [Response]; parsing and error
/// handling live in the repository.
class HeaderBannersApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  void cancelRequests() => _canceller.cancel();

  /// The published `header_main_page` banners, ordered by `index`.
  Future<Response> getHeaderBanners() {
    // ponytail: absolute dev-tunnel URL mirrors home_sections_api_service — the
    // feed + banners endpoints only exist on this backend, not the prod baseUrl.
    // Move to DioConstants.baseUrl + an endpoints const once prod has them.
    return _dio.get(
      '/api/v1/banners',
      queryParameters: <String, dynamic>{'type': 'header_main_page'},
      cancelToken: _canceller.token,
    );
  }
}
