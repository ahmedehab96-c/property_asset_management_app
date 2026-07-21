import 'package:shared_preferences/shared_preferences.dart';

/// تخزين مسار صورة الملف الشخصي محلياً.
class ProfileImageStore {
  static const _key = 'profile_image_path';

  static Future<String?> getPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> savePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, path);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
