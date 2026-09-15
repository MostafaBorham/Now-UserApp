import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';











class RecentKeywordsDatabaseService {
  const RecentKeywordsDatabaseService({
    required this.boxName,
    required this.key,
  });

  final String boxName;
  final String key;

  Box<dynamic> get _box => HiveManager.box(boxName);



  dynamic getRecentSearches() => _box.get(key);


  Future<void> saveRecentSearches(List<String> keywords) =>
      _box.put(key, keywords);


  Future<void> clearAll() => _box.delete(key);
}
