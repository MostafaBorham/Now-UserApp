import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';








class FeaturedStoresDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.featuredStores);




  String? getFeaturedStores() =>
      _box.get(HiveKeys.featuredStoresPayload) as String?;


  Future<void> saveFeaturedStores(String data) =>
      _box.put(HiveKeys.featuredStoresPayload, data);


  Future<void> clearFeaturedStores() =>
      _box.delete(HiveKeys.featuredStoresPayload);
}
