/// Constants used to configure the shared [Dio] instance.
abstract class DioConstants {
  static const String baseUrl = 'https://www.now-delivery.com';
  static const Duration timeout = Duration(seconds: 15);

  static const Map<String, String> defaultHeaders = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
