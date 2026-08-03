/// Constants used to configure the shared [Dio] instance.
abstract class DioConstants {
  static const String baseUrl = 'https://www.now-delivery.com';
  static const Duration timeout = Duration(seconds: 15);

  static const Map<String, String> defaultHeaders = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Base URL of the **Places API (New)**, used by the address search to turn a
  /// typed query into address suggestions. The legacy
  /// `maps.googleapis.com/maps/api/place/*` endpoints are not available to this
  /// Google Cloud project, so only the `v1` host below works.
  static const String placesBaseUrl = 'https://places.googleapis.com/v1';

  /// Key sent as `X-Goog-Api-Key` on every Places request.
  ///
  /// Same Google Cloud project as the Maps SDK key in `AndroidManifest.xml` /
  /// `AppDelegate.swift`. For Places calls to succeed the project must have
  /// **Places API (New)** enabled and the key's API restriction list must
  /// include `places.googleapis.com`.
  static const String googlePlacesApiKey =
      'AIzaSyBKKzXiqbhFhWMy61LGOlPv-RTFEM0WDys';
}