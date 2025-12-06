class KeranjangItem {
  String nama;
  String gambar;
  int jumlah;
  double harga;
  String kolaborasi;   
  String lokasi;       // ✅ lokasi produk
  bool dipilih;

  KeranjangItem({
    required this.nama,
    required this.gambar,
    required this.jumlah,
    required this.harga,
    required this.kolaborasi,
    required this.lokasi,     // ✅ tambahkan constructor
    this.dipilih = true,
  });

  Map<String, dynamic> toMap() {
    return {
      "nama": nama,
      "gambar": gambar,
      "jumlah": jumlah,
      "harga": harga,
      "kolaborasi": kolaborasi,
      "lokasi": lokasi,        // ✅ simpan lokasi
      "dipilih": dipilih,
    };
  }

  factory KeranjangItem.fromMap(Map<String, dynamic> map) {
    return KeranjangItem(
      nama: map["nama"] ?? "",
      gambar: map["gambar"] ?? "",
      jumlah: (map["jumlah"] is int)
          ? map["jumlah"]
          : int.tryParse(map["jumlah"].toString()) ?? 1,
      harga: (map["harga"] is double)
          ? map["harga"]
          : (map["harga"] is int)
              ? (map["harga"] as int).toDouble()
              : double.tryParse(map["harga"].toString()) ?? 0.0,
      kolaborasi: map["kolaborasi"] ?? "-",
      lokasi: map["lokasi"] ?? "Indonesia", // ✅ default biar aman
      dipilih: map["dipilih"] ?? true,
    );
  }
}
