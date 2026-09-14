import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Wipes every Hive box that holds data belonging to the signed-in user.
///
/// Invalidating the Riverpod providers on logout only drops the in-memory copy;
/// the Hive mirrors survive on disk. Since every user-scoped repository falls
/// back to its cache when the server is unreachable, a leftover box is served to
/// whoever signs in next — so the previous user's profile, orders, cards or
/// wallet can surface under someone else's account. Clearing on logout is what
/// keeps that from happening.
///
/// Only *user*-scoped boxes are cleared. Catalogue content is identical for
/// every user, so wiping it would just cost the next session a cold start with
/// no privacy gain.
class CachePurger {
  CachePurger._();

  /// Boxes whose contents describe the signed-in user and must not outlive the
  /// session. Keep in sync with [HiveBoxes] when a user-scoped box is added.
  static const List<String> _userScopedBoxes = <String>[
    HiveBoxes.userProfile,
    HiveBoxes.myOrders,
    HiveBoxes.myCards,
    HiveBoxes.walletInfo,
    HiveBoxes.recentSearches,
    HiveBoxes.recentAddressSearches,
  ];

  /// Clears every box in [_userScopedBoxes]. Each box is cleared independently
  /// so one failure cannot leave the rest behind, and the whole call is
  /// best-effort: logout must complete even if the disk does not cooperate.
  static Future<void> purgeUserData() async {
    for (final String name in _userScopedBoxes) {
      try {
        await HiveManager.box(name).clear();
      } catch (_) {}
    }
  }
}
