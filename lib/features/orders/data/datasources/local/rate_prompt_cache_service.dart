import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';

/// Remembers which delivered order the "rate your order" prompt was last shown
/// for, under [CacheKeys.ratePromptedOrderId], so it is offered once per order.
class RatePromptCacheService {
  bool wasPrompted(int orderId) =>
      SharedPrefManager.getString(CacheKeys.ratePromptedOrderId) == '$orderId';

  /// Best-effort: a failed write only means the prompt may show once more.
  Future<void> markPrompted(int orderId) async {
    await SharedPrefManager.setString(
      CacheKeys.ratePromptedOrderId,
      '$orderId',
    );
  }
}
