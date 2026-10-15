import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/remote/api/home_sections_endpoints.dart';

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
  ///
  /// [lat] / [lng] are the point the `nearby_stores` section is measured from.
  /// The backend uses a signed-in user's default address first and falls back
  /// to this pair only when there is none, so it is sent for every session.
  /// Both are sent together or not at all; with neither (and no saved address)
  /// `nearby_stores` comes back empty.
  ///
  /// `per_page` only sizes the `all_stores` section (the one paginated
  /// section): its "All" tab lists every store, so it asks for the most the
  /// backend serves in one page (100) rather than the default 15.
  ///
  /// The body comes back as the raw JSON string, undecoded: the repository
  /// decodes it and builds the models in one background isolate. At the
  /// feed's size Dio would otherwise decode it on the UI thread.
  /// The `all_stores` page size: the backend's maximum.
  static const int allStoresPerPage = 100;

  Future<Response> getHomeSections({
    required String platform,
    required String lang,
    double? lat,
    double? lng,
  }) {
    final bool hasLocation = lat != null && lng != null;
    return _dio.get(
      HomeSectionsEndpoints.getHomeSections,
      queryParameters: <String, dynamic>{
        'platform': platform,
        'lang': lang,
        'per_page': allStoresPerPage,
        if (hasLocation) 'lat': lat,
        if (hasLocation) 'lng': lng,
      },
      options: Options(responseType: ResponseType.plain),
      cancelToken: _canceller.token,
    );
  }
}
