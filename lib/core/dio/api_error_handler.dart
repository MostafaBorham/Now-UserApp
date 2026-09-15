
class ApiErrorHandler {
  ApiErrorHandler._();

  static const String _defaultMessage =
      'Something went wrong, please try again.';





  static String extractErrorMessage(Map<String, dynamic>? responseBody) {
    final dynamic message = responseBody?['message'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
    return _defaultMessage;
  }
}
