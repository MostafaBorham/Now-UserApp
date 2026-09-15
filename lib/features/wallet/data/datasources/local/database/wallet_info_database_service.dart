import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';








class WalletInfoDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.walletInfo);



  String? getWalletInfo() => _box.get(HiveKeys.walletInfoPayload) as String?;


  Future<void> saveWalletInfo(String data) =>
      _box.put(HiveKeys.walletInfoPayload, data);


  Future<void> clearWalletInfo() => _box.delete(HiveKeys.walletInfoPayload);
}
