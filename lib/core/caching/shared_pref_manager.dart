import 'package:shared_preferences/shared_preferences.dart';








class SharedPrefManager {
  SharedPrefManager._();

  static SharedPreferences? _prefs;


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


  static Future<bool> setString(String key, String value) =>
      _instance.setString(key, value);

  static String? getString(String key) => _instance.getString(key);


  static Future<bool> setBool(String key, bool value) =>
      _instance.setBool(key, value);



  static bool? getBool(String key) => _instance.getBool(key);

  static bool containsKey(String key) => _instance.containsKey(key);


  static Future<bool> remove(String key) => _instance.remove(key);
}
