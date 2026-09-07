import 'package:nowdelivery_user_app/core/utils/uuid.dart';

/// Holds the idempotency key for a retryable, non-idempotent request (order
/// placement).
///
/// The server dedupes by this key: the same key with the same request replays
/// the original result, while the same key with a *different* request is
/// rejected. So the key must be reused across retries of an unchanged submit
/// (a retry after a lost response then replays instead of duplicating) and
/// rotated whenever the request changes or after it has succeeded (a genuine
/// repeat must not replay the previous result).
///
/// The caller supplies a [fingerprint] of exactly the fields the server hashes;
/// this class owns only the reuse-vs-rotate decision.
class IdempotencyKey {
  String? _key;
  String? _fingerprint;
  bool _consumed = false;

  /// The key to send for a request with [fingerprint]. Reuses the current key
  /// while the fingerprint is unchanged and the key hasn't been consumed by a
  /// success; otherwise mints a new one. [generate] is injectable for tests and
  /// defaults to a v4 UUID.
  String forRequest(String fingerprint, {String Function()? generate}) {
    if (_key == null || _consumed || fingerprint != _fingerprint) {
      _key = (generate ?? generateUuidV4)();
      _fingerprint = fingerprint;
      _consumed = false;
    }
    return _key!;
  }

  /// Marks the current key as consumed by a successful request, so the next
  /// [forRequest] mints a fresh key even if the fingerprint matches.
  void markConsumed() => _consumed = true;
}
