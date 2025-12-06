import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String keyIsLogin = "isLoggedIn";

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLogin) ?? false;
  }

  static Future<void> setLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLogin, true);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLogin, false);
  }
}
