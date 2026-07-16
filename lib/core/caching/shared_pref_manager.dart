import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] — the single entry point for
/// key/value caching in the app (the caching counterpart of `DioFactory`).
///
/// [init] must be awaited once in `main()` before `runApp`; after that all
/// reads are synchronous. Feature cache services consume this manager with
/// keys from `CacheKeys` — no other layer should import `shared_preferences`
/// directly.
class SharedPrefManager {
  SharedPrefManager._();

  static SharedPreferences? _prefs;

  /// Loads the [SharedPreferences] instance. Call once at app startup.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    final SharedPreferences? prefs = _prefs;
    if (prefs == null) {
      throw StateError('SharedPrefManager.init() must be awaited before use.');
    }
    return prefs;
  }

  /// Returns `true` when the value was persisted successfully.
  static Future<bool> setString(String key, String value) =>
      _instance.setString(key, value);

  static String? getString(String key) => _instance.getString(key);

  static bool containsKey(String key) => _instance.containsKey(key);

  /// Returns `true` when the value was removed successfully.
  static Future<bool> remove(String key) => _instance.remove(key);
}
