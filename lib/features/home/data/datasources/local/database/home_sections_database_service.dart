import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';








class HomeSectionsDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.homeSections);



  String? getHomeSections() =>
      _box.get(HiveKeys.homeSectionsPayload) as String?;


  Future<void> saveHomeSections(String data) =>
      _box.put(HiveKeys.homeSectionsPayload, data);


  Future<void> clearHomeSections() =>
      _box.delete(HiveKeys.homeSectionsPayload);
}
