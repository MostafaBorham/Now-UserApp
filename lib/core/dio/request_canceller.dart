import 'package:dio/dio.dart';

/// Owns the [CancelToken] lifecycle for a single API service.
///
/// This is the only place (besides the API services that consume [token])
/// that knows about [CancelToken]. Upper layers (repos, viewmodels, widgets)
/// must never import it — they only call a plain `cancelRequests()` method
/// that the API service exposes and the repo forwards.
///
/// A cancelled [CancelToken] is dead forever, so [token] transparently
/// replaces it with a fresh one on the next request after a [cancel].
class RequestCanceller {
  CancelToken _token = CancelToken();

  /// The token to attach to outgoing requests.
  CancelToken get token {
    if (_token.isCancelled) {
      _token = CancelToken();
    }
    return _token;
  }

  /// Cancels every in-flight request that carries the current token.
  /// Safe to call multiple times or with no pending requests.
  void cancel() {
    if (!_token.isCancelled) {
      _token.cancel();
    }
  }
}