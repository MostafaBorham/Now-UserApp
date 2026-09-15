import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';








class HeaderBannersDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.headerBanners);




  String? getHeaderBanners() =>
      _box.get(HiveKeys.headerBannersPayload) as String?;


  Future<void> saveHeaderBanners(String data) =>
      _box.put(HiveKeys.headerBannersPayload, data);


  Future<void> clearHeaderBanners() =>
      _box.delete(HiveKeys.headerBannersPayload);
}
