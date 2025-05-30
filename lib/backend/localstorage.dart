import 'package:shared_preferences/shared_preferences.dart';

class Localstorage {
  final String _tokenKey = 'token';

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) {
      throw Exception('Token not found in local storage');
    }
    return token;
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setString(_tokenKey, token);
    if (!success) {
      throw Exception('Failed to save token to local storage');
    }
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.remove(_tokenKey);
    if (!success) {
      throw Exception('Failed to remove token from local storage');
    }
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
