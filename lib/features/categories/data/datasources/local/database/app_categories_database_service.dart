import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

class AppCategoriesDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.appCategories);

  String? getAppCategories() =>
      _box.get(HiveKeys.appCategoriesPayload) as String?;

  Future<void> saveAppCategories(String data) =>
      _box.put(HiveKeys.appCategoriesPayload, data);

  Future<void> clearAppCategories() =>
      _box.delete(HiveKeys.appCategoriesPayload);
}
