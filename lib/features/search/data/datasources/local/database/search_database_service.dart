import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the search feature's recent keywords.
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// recent-searches box and return whatever Hive holds, as-is. No error
/// handling and no formatting live here — the repository casts the raw value,
/// applies the recents rules (dedup / trim / filter), and maps failures into a
/// `Failure`.
class SearchDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.recentSearches);

  /// Returns the raw value stored under [HiveKeys.recentSearchKeywords]
  /// (a `List` when present), or `null` when nothing has been saved yet.
  dynamic getRecentSearches() => _box.get(HiveKeys.recentSearchKeywords);

  /// Overwrites the stored recent keywords with [keywords].
  Future<void> saveRecentSearches(List<String> keywords) =>
      _box.put(HiveKeys.recentSearchKeywords, keywords);

  /// Removes the stored recent keywords entirely.
  Future<void> clearAll() => _box.delete(HiveKeys.recentSearchKeywords);
}
