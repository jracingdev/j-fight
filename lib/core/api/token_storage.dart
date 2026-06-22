import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _key = 'jfight_access_token';
  static const _storage = FlutterSecureStorage();

  static Future<String?> read() async {
    try {
      final secure = await _storage.read(key: _key);
      if (secure != null && secure.isNotEmpty) return secure;
    } catch (e) {
      debugPrint('TokenStorage.read secure: $e');
    }
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_key);
      } catch (e) {
        debugPrint('TokenStorage.read prefs: $e');
      }
    }
    return null;
  }

  static Future<void> write(String token) async {
    try {
      await _storage.write(key: _key, value: token);
    } catch (e) {
      debugPrint('TokenStorage.write secure: $e');
    }
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, token);
    }
  }

  static Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (e) {
      debugPrint('TokenStorage.clear secure: $e');
    }
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    }
  }
}
