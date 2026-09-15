import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';








class ProfileDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.userProfile);



  String? getProfile() => _box.get(HiveKeys.userProfilePayload) as String?;


  Future<void> saveProfile(String data) =>
      _box.put(HiveKeys.userProfilePayload, data);




}
