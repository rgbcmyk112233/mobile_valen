import 'dart:convert';
import 'package:http/http.dart' as http;

class Produk {
  final int id;
  final String namaProduk;
  final String deskripsi;
  final String kolaborasi;
  final String gambar;
  final int harga;
  final String lokasi; // ✅ tambah

  Produk({
    required this.id,
    required this.namaProduk,
    required this.deskripsi,
    required this.kolaborasi,
    required this.gambar,
    required this.harga,
    required this.lokasi, // ✅ tambah
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'],
      namaProduk: json['namaProduk'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      kolaborasi: json['kolaborasi'] ?? '',
      gambar: json['gambar'] ?? '',
      harga: json['harga'] ?? 0,
      lokasi: json['lokasi'] ?? "-", // ✅ ambil dari API
    );
  }
}

class ApiProduk {
  static const String baseUrl =
      "https://api.sheety.co/bbb8b4389560e0f66169374c4062700b/nakamerch/sheet1";

  static Future<List<Produk>> ambilProduk() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["sheet1"] != null) {
          return (data["sheet1"] as List)
              .map((e) => Produk.fromJson(e))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print("Error ambil produk: $e");
      return [];
    }
  }
}
