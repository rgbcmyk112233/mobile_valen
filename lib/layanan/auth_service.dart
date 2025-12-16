import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_service.dart';
import '../util/enkripsi.dart';
import '../halaman/login.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // -------------------------------------------------------------
  // GUARD (SATPAM / GUEST MODE)
  // -------------------------------------------------------------
  Future<void> guard(BuildContext context, VoidCallback onSuccessAction) async {
    bool loginStatus = await isLoggedIn();

    if (loginStatus) {
      onSuccessAction();
    } else {
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      ).then((isLoginSuccess) {
        if (isLoginSuccess == true) {
          onSuccessAction();
        }
      });
    }
  }

  // -------------------------------------------------------------
  // REGISTER
  // -------------------------------------------------------------
  Future<bool> register(String nama, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final safeEmail = email.trim();

    if (prefs.getString('user_email') == safeEmail) return false;

    String hashedPassword = Enkripsi.hashPassword(password);

    // Simpan Data User (Nama, Email, Pass) ke Disk
    await prefs.setString('user_name', nama);
    await prefs.setString('user_email', safeEmail);
    await prefs.setString('user_password', hashedPassword);

    // Sinkronisasi status login ke semua sistem
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('isLoggedIn', true);

    await prefs.setString('logged_email', safeEmail);
    await prefs.setString('current_user', safeEmail);

    // PERBAIKAN DI SINI:
    // Mengirim 2 argumen (email DAN nama) sesuai perubahan di LocalService
    await LocalService.loginUser(safeEmail, nama);

    return true;
  }

  // -------------------------------------------------------------
  // LOGIN
  // -------------------------------------------------------------
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final savedEmail = prefs.getString('user_email');
    final savedPassHash = prefs.getString('user_password');
    // PERBAIKAN: Ambil nama yang tersimpan
    final savedName = prefs.getString('user_name') ?? "User";

    final inputEmail = email.trim();

    bool isPasswordCorrect = false;
    if (savedPassHash != null) {
      isPasswordCorrect = Enkripsi.verifyPassword(password, savedPassHash);
    }

    if (inputEmail == savedEmail && isPasswordCorrect) {
      // sinkronisasi status login
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('isLoggedIn', true);

      await prefs.setString('logged_email', inputEmail);
      await prefs.setString('current_user', inputEmail);

      // PERBAIKAN DI SINI:
      // Mengirim 2 argumen (email DAN nama)
      await LocalService.loginUser(inputEmail, savedName);

      return true;
    }

    return false;
  }

  // -------------------------------------------------------------
  // CHECK
  // -------------------------------------------------------------
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // -------------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_logged_in', false);
    await prefs.setBool('isLoggedIn', false);

    await prefs.remove('logged_email');

    await LocalService.logoutUser();
  }

  // -------------------------------------------------------------
  // GET NAME
  // -------------------------------------------------------------
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }
}