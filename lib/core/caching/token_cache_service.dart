import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';

/// The single source of truth for the three session tokens the app persists.
///
/// Tokens are an app-wide concern — read by `AuthTokenInterceptor`, the router
/// redirects, and the token-refresh flow — so they live here in the core
/// caching layer instead of being duplicated across feature cache services.
///
/// Three distinct tokens are stored under their own keys ([CacheKeys]):
///
/// * [getGuestToken] — the guest session; sent as `X-Guest-Token`. Issued only
///   when continuing as a guest from onboarding.
/// * [getAccessToken] — the logged-in user's bearer token; sent as
///   `Authorization: Bearer`. Issued by OTP verification and by a refresh.
/// * [getRefreshToken] — used only to mint a fresh access token on a `401`.
///
/// Reads are tolerant: a missing value returns `null` (never throws), so a
/// cold cache can never crash a redirect or an interceptor. Writes and removals
/// surface failures as [CacheException] for callers to map into a `Failure`.
class TokenCacheService {
  // ---- Guest token ---------------------------------------------------------

  String? getGuestToken() => SharedPrefManager.getString(CacheKeys.guestToken);

  /// Persists the guest token, replacing any previous guest token.
  Future<void> saveGuestToken(String token) async {
    final bool saved =
        await SharedPrefManager.setString(CacheKeys.guestToken, token);
    if (!saved) {
      throw const CacheException(CacheException.saveGuestSessionFailedMessage);
    }
  }

  // ---- Access token --------------------------------------------------------

  String? getAccessToken() =>
      SharedPrefManager.getString(CacheKeys.accessToken);

  /// Persists the access token on its own (e.g. after a refresh that only
  /// returned a new access token).
  Future<void> saveAccessToken(String token) async {
    final bool saved =
        await SharedPrefManager.setString(CacheKeys.accessToken, token);
    if (!saved) {
      throw const CacheException(CacheException.saveUserSessionFailedMessage);
    }
  }

  // ---- Refresh token -------------------------------------------------------

  String? getRefreshToken() =>
      SharedPrefManager.getString(CacheKeys.refreshToken);

  /// Persists the refresh token on its own.
  Future<void> saveRefreshToken(String token) async {
    final bool saved =
        await SharedPrefManager.setString(CacheKeys.refreshToken, token);
    if (!saved) {
      throw const CacheException(CacheException.saveUserSessionFailedMessage);
    }
  }

  // ---- Composite operations ------------------------------------------------

  /// Persists the access and refresh tokens together — the pair issued by OTP
  /// verification and by the refresh endpoint. Both must succeed.
  Future<void> saveUserTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  /// `true` when a logged-in user's access token is cached — the single test
  /// used across the app to tell a user session from a guest session.
  bool get hasAccessToken => (getAccessToken() ?? '').isNotEmpty;

  /// `true` when a guest token is cached.
  bool get hasGuestToken => (getGuestToken() ?? '').isNotEmpty;

  // ---- Removal -------------------------------------------------------------

  /// Removes the access and refresh tokens (logout), leaving the app in a
  /// logged-out state.
  ///
  /// A key that was never written is treated as already removed — the caller
  /// asked for it to be gone, and it is. Only a token that is still readable
  /// afterwards is a real failure, because that is the one case where the app
  /// would carry on believing it is signed in.
  Future<void> clearUserTokens() async {
    await SharedPrefManager.remove(CacheKeys.accessToken);
    await SharedPrefManager.remove(CacheKeys.refreshToken);

    if (hasAccessToken || (getRefreshToken() ?? '').isNotEmpty) {
      throw const CacheException(CacheException.clearUserSessionFailedMessage);
    }
  }

  /// Removes the guest token. Same rule as [clearUserTokens]: absent counts as
  /// removed. Login clears the guest token right after saving the user's pair,
  /// so throwing over a guest token that never existed would report a failure
  /// on a session that is in fact signed in.
  Future<void> clearGuestToken() async {
    await SharedPrefManager.remove(CacheKeys.guestToken);

    if (hasGuestToken) {
      throw const CacheException(CacheException.clearUserSessionFailedMessage);
    }
  }
}
