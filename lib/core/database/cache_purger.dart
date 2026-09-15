import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';













class CachePurger {
  CachePurger._();



  static const List<String> _userScopedBoxes = <String>[
    HiveBoxes.userProfile,
    HiveBoxes.myOrders,
    HiveBoxes.myCards,
    HiveBoxes.walletInfo,
    HiveBoxes.recentSearches,
    HiveBoxes.recentAddressSearches,
  ];




  static Future<void> purgeUserData() async {
    for (final String name in _userScopedBoxes) {
      try {
        await HiveManager.box(name).clear();
      } catch (_) {}
    }
  }
}
