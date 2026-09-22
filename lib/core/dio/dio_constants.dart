abstract class DioConstants {
  static const String baseUrl = 'https://backend.now-delivery.com';
  static const Duration timeout = Duration(seconds: 15);

  static const int isolateDecodeThreshold = 30 * 1024;

  static const Map<String, String> defaultHeaders = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static const String placesBaseUrl = 'https://places.googleapis.com/v1';

  static const String googlePlacesApiKey =
      'AIzaSyBKKzXiqbhFhWMy61LGOlPv-RTFEM0WDys';
}
