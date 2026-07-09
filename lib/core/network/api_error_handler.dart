/// Shared helpers for interpreting API error responses.
class ApiErrorHandler {
  ApiErrorHandler._();

  static const String _defaultMessage =
      'Something went wrong, please try again.';

  /// Extracts the failure `message` from a response body [Map].
  ///
  /// Falls back to a generic message when the body is null or has no usable
  /// `message` field.
  static String extractErrorMessage(Map<String, dynamic>? responseBody) {
    final dynamic message = responseBody?['message'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
    return _defaultMessage;
  }
}
