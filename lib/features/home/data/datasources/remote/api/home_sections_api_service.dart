import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';

/// Raw API calls for the home feed.
///
/// Only performs the request and returns the Dio [Response]; parsing and error
/// handling live in the repository. Cancellation is encapsulated here — every
/// request carries [_canceller]'s token and callers only see [cancelRequests].
class HomeSectionsApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  void cancelRequests() => _canceller.cancel();

  /// [platform] is `ios` / `android` (the backend falls back to `all` for any
  /// other value); [lang] (`ar` / `en`) makes the feed return localized titles.
  Future<Response> getHomeSections({
    required String platform,
    required String lang,
  }) {
    return _dio.get(
      "https://caliber-surgery-sanctuary.ngrok-free.dev/api/v1/home-sections",
      queryParameters: <String, dynamic>{'platform': platform, 'lang': lang},
      cancelToken: _canceller.token,
    );
  }
}
