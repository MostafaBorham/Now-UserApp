import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';

/// Local store for the first-order welcome voucher code, persisted as a raw
/// string under [CacheKeys.welcomeVoucherCode].
///
/// The [PromotionRepo] refreshes this from the server on every splash and reads
/// it back when the server is unreachable, so the empty cart and guest settings
/// can still show a promo code offline. Reads are tolerant — a cold or blank
/// cache returns `null` — so nothing downstream ever crashes on a missing code.
class WelcomeVoucherCacheService {
  /// The cached welcome code, or `null` when nothing valid is stored yet.
  String? getWelcomeCode() {
    final String? code = SharedPrefManager.getString(
      CacheKeys.welcomeVoucherCode,
    );
    if (code == null || code.isEmpty) return null;
    return code;
  }

  /// Persists [code] as the latest welcome voucher code. Best-effort: a failed
  /// write simply leaves the previous value in place.
  Future<void> saveWelcomeCode(String code) async {
    await SharedPrefManager.setString(CacheKeys.welcomeVoucherCode, code);
  }
}
