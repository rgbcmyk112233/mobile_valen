import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'keranjang_item.dart'; // Pastikan path ini sesuai file Anda

class LocalService {
  // -------------------------------------------------------------
  // LOGIN USER
  // -------------------------------------------------------------
  // UPDATED: Tambah parameter 'nama' agar tersimpan di memori HP
  static Future<void> loginUser(String email, String nama) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("is_logged_in", true);
    await prefs.setBool("isLoggedIn", true); // Sinkron SessionManager lama
    
    // Simpan Email
    await prefs.setString("current_user", email);
    await prefs.setString("logged_email", email);
    
    // BARU: Simpan Nama
    await prefs.setString("current_user_name", nama);

    debugPrint("LocalService.loginUser -> User: $email, Nama: $nama");
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_logged_in") ?? false;
  }

  // -------------------------------------------------------------
  // GET CURRENT USER DATA
  // -------------------------------------------------------------
  
  // Ambil Email (Digunakan untuk key keranjang)
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    final a = prefs.getString("current_user");
    if (a != null && a.isNotEmpty) return a;

    final b = prefs.getString("logged_email");
    if (b != null && b.isNotEmpty) return b;

    final c = prefs.getString("user_email");
    if (c != null && c.isNotEmpty) return c;

    return null;
  }

  // BARU: Ambil Nama (Digunakan untuk Dashboard)
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("current_user_name");
  }

  // -------------------------------------------------------------
  // LOGOUT USER
  // -------------------------------------------------------------
  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("is_logged_in", false);
    await prefs.setBool("isLoggedIn", false);
    
    // Hapus data sesi aktif
    await prefs.remove("current_user");
    await prefs.remove("current_user_name"); // Hapus nama juga

    debugPrint("LocalService.logoutUser -> Sesi dihapus");
  }

  // -------------------------------------------------------------
  // LOGIKA KERANJANG (Tidak Diubah)
  // -------------------------------------------------------------
  
  static Future<String?> _cartKey() async {
    final email = await getCurrentUser();
    if (email == null) return null;
    return "cart_$email";
  }

  static Future<void> saveKeranjang(List<KeranjangItem> keranjang) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _cartKey();
    if (key == null) return;

    List<String> data = keranjang.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(key, data);
  }

  static Future<List<KeranjangItem>> loadKeranjang() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _cartKey();
    if (key == null) return [];

    List<String>? data = prefs.getStringList(key);
    if (data == null) return [];

    try {
      return data.map((e) => KeranjangItem.fromMap(jsonDecode(e))).toList();
    } catch (e) {
      debugPrint("LocalService.loadKeranjang decode error: $e");
      return [];
    }
  }

  static Future<void> addToKeranjang(KeranjangItem item) async {
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