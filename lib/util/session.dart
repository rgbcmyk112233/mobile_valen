import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Key yang harus SAMA PERSIS dengan AuthService & LocalService
  static const String keyIsLogin = "is_logged_in";
  static const String keyUserName = "user_name";
  static const String keyUserEmail = "user_email";

  /// Cek Status Login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Mengembalikan false jika null
    return prefs.getBool(keyIsLogin) ?? false;
  }

  /// Simpan Sesi (Status + Data User)
  static Future<void> saveSession(String? nama, String? email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLogin, true);
    
    if (nama != null) {
      await prefs.setString(keyUserName, nama);
    }
    if (email != null) {
      await prefs.setString(keyUserEmail, email);
    }
  }

  /// Ambil Nama User (Untuk Dashboard)
  static Future<String?> getActiveName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName);
  }

  /// Hapus Sesi (Logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Hapus status login
    await prefs.setBool(keyIsLogin, false);
    
    // Hapus data user agar bersih
    await prefs.remove(keyUserName);
    await prefs.remove(keyUserEmail);
  }
}