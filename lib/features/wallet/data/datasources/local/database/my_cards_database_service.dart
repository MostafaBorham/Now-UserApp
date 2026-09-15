import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';








class MyCardsDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.myCards);



  String? getMyCards() => _box.get(HiveKeys.myCardsPayload) as String?;


  Future<void> saveMyCards(String data) =>
      _box.put(HiveKeys.myCardsPayload, data);


  Future<void> clearMyCards() => _box.delete(HiveKeys.myCardsPayload);
}
