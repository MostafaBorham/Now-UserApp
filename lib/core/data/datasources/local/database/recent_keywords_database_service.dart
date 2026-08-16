import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for a list of recent search keywords.
///
/// The Hive counterpart of an API service: its only role is to read/write one
/// box entry and return whatever Hive holds, as-is. No error handling and no
/// formatting live here — `RecentKeywordsRepo` casts the raw value, applies the
/// recents rules (dedup / trim / filter), and maps failures into a `Failure`.
///
/// Each search that keeps its own recents (products, addresses, …) points an
/// instance at its own [boxName] / [key] pair, so one search's terms never
/// surface in another's.
class RecentKeywordsDatabaseService {
  const RecentKeywordsDatabaseService({
    required this.boxName,
    required this.key,
  });

  final String boxName;
  final String key;

  Box<dynamic> get _box => HiveManager.box(boxName);

  /// Returns the raw value stored under [key] (a `List` when present), or
  /// `null` when nothing has been saved yet.
  dynamic getRecentSearches() => _box.get(key);

  /// Overwrites the stored recent keywords with [keywords].
  Future<void> saveRecentSearches(List<String> keywords) =>
      _box.put(key, keywords);

  /// Removes the stored recent keywords entirely.
  Future<void> clearAll() => _box.delete(key);
}
