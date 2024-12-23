import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static const String _localStorageKey = 'app_local_storage';
  
  static Future<void> saveLocalStorage(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localStorageKey, data);
  }

  static Future<String?> getLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localStorageKey);
  }
}