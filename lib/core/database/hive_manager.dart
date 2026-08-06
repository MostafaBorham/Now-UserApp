import 'package:hive_flutter/hive_flutter.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';

/// Thin wrapper around Hive — the single entry point for Hive-backed local
/// storage in the app (the Hive counterpart of `SharedPrefManager` /
/// `DioFactory`).
///
/// [init] must be awaited once in `main()` before `runApp`; it initializes
/// Hive for Flutter and opens every box the app uses, so all later box access
/// is synchronous. Feature cache services reach their box through [box] with
/// names from `HiveBoxes` — no other layer should import `hive`/`hive_flutter`
/// directly.
class HiveManager {
  HiveManager._();

  static bool _initialized = false;

  /// Initializes Hive and opens all app boxes. Call once at app startup.
  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(HiveBoxes.recentSearches);
    await Hive.openBox<dynamic>(HiveBoxes.recentAddressSearches);
    await Hive.openBox<dynamic>(HiveBoxes.myOrders);
    _initialized = true;
  }

  /// Returns an already-opened box by [name] (declared in `HiveBoxes`).
  static Box<dynamic> box(String name) {
    if (!_initialized) {
      throw StateError('HiveManager.init() must be awaited before use.');
    }
    return Hive.box<dynamic>(name);
  }
}
