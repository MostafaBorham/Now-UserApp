import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';








class AppInfoDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.appInfo);



  String? getAppInfo() => _box.get(HiveKeys.appInfoPayload) as String?;


  Future<void> saveAppInfo(String data) =>
      _box.put(HiveKeys.appInfoPayload, data);


  Future<void> clearAppInfo() => _box.delete(HiveKeys.appInfoPayload);
}
