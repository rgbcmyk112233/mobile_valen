// lib/layanan/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'local_service.dart';

class AuthService {
  /// Register user (lokal). Jika email sudah ada, return false.
  Future<bool> register(String nama, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString('user_email') == email) return false;

    await prefs.setString('user_name', nama);
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);

    // Tandai sudah login dan simpan email yang logged
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('logged_email', email);

    // Pastikan LocalService juga tahu user sekarang (simpan current_user)
    await LocalService.loginUser(email);

    return true;
  }

  /// Login dengan mencocokkan SharedPreferences
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final savedEmail = prefs.getString('user_email');
    final savedPass = prefs.getString('user_password');

    if (email == savedEmail && password == savedPass) {
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('logged_email', email);

      // Pastikan LocalService juga tahu user sekarang (simpan current_user)
      await LocalService.loginUser(email);

      return true;
    }
    return false;
  }

  /// Cek apakah user sedang login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// Logout (hanya toggle flag). Data user tetap ada (sesuai kebutuhanmu).
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('logged_email');

    // juga clear current_user di LocalService
    await LocalService.logoutUser();
  }

  /// Ambil nama user jika ada
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  /// Ambil email user jika ada
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('logged_email') ?? prefs.getString('user_email');
  }
}
