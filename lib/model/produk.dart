class Produk {
  final String gambar;
  final String namaProduk;
  final String kolaborasi;
  final String deskripsi;
  final int harga;
  final int id;
  final String lokasi;

  Produk({
    required this.gambar,
    required this.namaProduk,
    required this.kolaborasi,
    required this.deskripsi,
    required this.harga,
    required this.id,
    required this.lokasi,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      gambar: json['gambar'] ?? '',
      namaProduk: json['namaProduk'] ?? '',
      kolaborasi: json['kolaborasi'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: json['harga'] ?? 0,
      id: json['id'] ?? 0,
      lokasi: json['lokasi'] ?? '',
    );
  }
}
