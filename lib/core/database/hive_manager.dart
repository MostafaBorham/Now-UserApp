import 'package:hive_flutter/hive_flutter.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';










class HiveManager {
  HiveManager._();

  static bool _initialized = false;


  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(HiveBoxes.recentSearches);
    await Hive.openBox<dynamic>(HiveBoxes.recentAddressSearches);
    await Hive.openBox<dynamic>(HiveBoxes.myOrders);
    await Hive.openBox<dynamic>(HiveBoxes.appInfo);
    await Hive.openBox<dynamic>(HiveBoxes.appCategories);
    await Hive.openBox<dynamic>(HiveBoxes.userProfile);
    await Hive.openBox<dynamic>(HiveBoxes.myCards);
    await Hive.openBox<dynamic>(HiveBoxes.walletInfo);
    await Hive.openBox<dynamic>(HiveBoxes.homeSections);
    await Hive.openBox<dynamic>(HiveBoxes.headerBanners);
    await Hive.openBox<dynamic>(HiveBoxes.featuredStores);
    _initialized = true;
  }


  static Box<dynamic> box(String name) {
    if (!_initialized) {
      throw StateError('HiveManager.init() must be awaited before use.');
    }
    return Hive.box<dynamic>(name);
  }
}
