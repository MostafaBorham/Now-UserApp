import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the address search's recent keywords.
///
/// The address counterpart of `SearchDatabaseService`, pointed at its own box
/// so an area the user searched for never surfaces as a product keyword. Its
/// only role is to read/write the box and return whatever Hive holds, as-is —
/// the repository casts the value, applies the recents rules and maps failures
/// into a `Failure`.
class AddressSearchDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.recentAddressSearches);

  /// Returns the raw value stored under
  /// [HiveKeys.recentAddressSearchKeywords] (a `List` when present), or `null`
  /// when nothing has been saved yet.
  dynamic getRecentSearches() =>
      _box.get(HiveKeys.recentAddressSearchKeywords);

  /// Overwrites the stored recent keywords with [keywords].
  Future<void> saveRecentSearches(List<String> keywords) =>
      _box.put(HiveKeys.recentAddressSearchKeywords, keywords);

  /// Removes the stored recent keywords entirely.
  Future<void> clearAll() => _box.delete(HiveKeys.recentAddressSearchKeywords);
}
