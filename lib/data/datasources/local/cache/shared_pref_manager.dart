import 'package:shared_preferences/shared_preferences.dart';


abstract class SharedPrefManager {

  static late final SharedPreferences _prefs;

  static Future init() async{
    _prefs = await SharedPreferences.getInstance();
  }
  static Future<bool> saveString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (_) {
      return false;
    }
  }

  static Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> saveInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (_) {
      return false;
    }
  }

  static Future<int?> getInt(String key) async {
    try {
      return _prefs.getInt(key);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> saveDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (_) {
      return false;
    }
  }

  static Future<double?> getDouble(String key) async {
    try {
      return _prefs.getDouble(key);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> saveBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (_) {
      return false;
    }
  }

  static Future<bool?> getBool(String key) async {
    try {
      return _prefs.getBool(key);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> saveStringList(
      String key,
      List<String> value,
      ) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (_) {
      return false;
    }
  }

  static Future<List<String>?> getStringList(String key) async {
    try {
      return _prefs.getStringList(key);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> containsKey(String key) async {
    try {
      return _prefs.containsKey(key);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (_) {
      return false;
    }
  }
}