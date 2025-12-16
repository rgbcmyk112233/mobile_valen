import 'dart:convert';
import 'package:crypto/crypto.dart';

class Enkripsi {
  static const String _salt = "NakaMerch2025"; // biar hash lebih aman

  static String hashPassword(String password) {
    final bytes = utf8.encode(password + _salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String inputPassword, String hashedPassword) {
    return hashPassword(inputPassword) == hashedPassword;
  }
}
