// lib/layanan/local_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'keranjang_item.dart';

class LocalService {
  // ✅ Simpan status login & user email
  static Future<void> loginUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_logged_in", true);
    await prefs.setString("current_user", email);
    // keep also logged_email for compatibility
    await prefs.setString("logged_email", email);
    debugPrint("LocalService.loginUser -> current_user set: $email");
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_logged_in") ?? false;
  }

  /// coba ambil dari beberapa key supaya kompatibel
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final a = prefs.getString("current_user");
    if (a != null && a.isNotEmpty) {
      debugPrint("LocalService.getCurrentUser -> from current_user: $a");
      return a;
    }
    final b = prefs.getString("logged_email");
    if (b != null && b.isNotEmpty) {
      debugPrint("LocalService.getCurrentUser -> from logged_email: $b");
      return b;
    }
    final c = prefs.getString("user_email");
    if (c != null && c.isNotEmpty) {
      debugPrint("LocalService.getCurrentUser -> from user_email: $c");
      return c;
    }
    debugPrint("LocalService.getCurrentUser -> null");
    return null;
  }

  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_logged_in", false);
    await prefs.remove("current_user");
    // keep logged_email/user_email if you want; we removed current_user
    debugPrint("LocalService.logoutUser -> current_user removed");
  }

  static Future<String?> _cartKey() async {
    final email = await getCurrentUser();
    if (email == null) return null;
    return "cart_$email";
  }

  // ✅ Simpan keranjang
  static Future<void> saveKeranjang(List<KeranjangItem> keranjang) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _cartKey();
    if (key == null) {
      debugPrint("LocalService.saveKeranjang -> key null, tidak menyimpan");
      return;
    }

    List<String> data = keranjang.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(key, data);
    debugPrint("LocalService.saveKeranjang -> disimpan $key (${keranjang.length} item)");
  }

  // ✅ Ambil keranjang
  static Future<List<KeranjangItem>> loadKeranjang() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _cartKey();
    if (key == null) {
      debugPrint("LocalService.loadKeranjang -> key null, kembalikan []");
      return [];
    }

    List<String>? data = prefs.getStringList(key);
    if (data == null) return [];

    try {
      return data.map((e) => KeranjangItem.fromMap(jsonDecode(e))).toList();
    } catch (e) {
      debugPrint("LocalService.loadKeranjang decode error: $e");
      return [];
    }
  }

  // ✅ Tambah item ke keranjang (merge qty)
  static Future<void> addToKeranjang(KeranjangItem item) async {
    debugPrint("LocalService.addToKeranjang -> tambah ${item.nama} x${item.jumlah}");
    final keranjang = await loadKeranjang();

    final idx = keranjang.indexWhere(
      (x) => x.nama == item.nama && x.gambar == item.gambar,
    );

    if (idx >= 0) {
      keranjang[idx].jumlah += item.jumlah;
    } else {
      keranjang.add(item);
    }

    await saveKeranjang(keranjang);
  }

  static Future<void> clearKeranjang() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _cartKey();
    if (key == null) return;
    await prefs.remove(key);
  }
}
