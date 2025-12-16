import 'package:flutter/material.dart';
import '../halaman/toko.dart';
import '../tema/warna.dart';
import '../layanan/api_produk.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  late Future<List<Produk>> _daftarProduk;
  String searchQuery = "";
  double hargaMax = 999999999;

  @override
  void initState() {
    super.initState();
    _daftarProduk = ApiProduk.ambilProduk();
  }

  // --- LOGIC UI UNTUK SECTION BRAND (DIPERBARUI) ---
  List<Widget> _buildBrandSections(List<Produk> produkList) {
    final Map<String, List<Produk>> grouped = {};

    // 1. Kelompokkan produk berdasarkan Brand/Kolaborasi
    for (var p in produkList) {
      final brand = p.kolaborasi.isNotEmpty ? p.kolaborasi : 'Unknown';
      grouped.putIfAbsent(brand, () => []);
      grouped[brand]!.add(p);
    }

    List<Widget> sections = [];

    grouped.forEach((brand, items) {
      // Kita tidak perlu .take(4) lagi karena ini bisa di-scroll
      // Tapi jika ingin membatasi, bisa tambahkan .take(10)

      sections.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Brand
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                brand,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600, // Sedikit lebih tebal agar tegas
                  color: WarnaTema.pirateBlack,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // List Horizontal (Scrollable)
            SizedBox(
              height: 180, // Tinggi area scroll
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ), // Padding kiri kanan list
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 12), // Jarak antar kartu
                itemBuilder: (context, index) {
                  final produk = items[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TokoScreen(brand: produk.kolaborasi),
                        ),
                      );
                    },
                    // Container pembungkus dengan lebar TETAP
                    child: SizedBox(
                      width: 140, // Lebar kartu fix (tidak melar)
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gambar Produk
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                produk.gambar,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (c, e, s) =>
                                    Container(color: Colors.grey[300]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Opsional: Menampilkan Harga/Nama kecil di bawah (Clean Look)
                          // Jika ingin benar-benar polos, hapus Text di bawah ini
                          Text(
                            produk.namaProduk,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "Rp ${produk.harga}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: WarnaTema.pirateBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24), // Jarak antar section brand
          ],
        ),
      );
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaTema.softGrey,

      // --- HEADER ---
      appBar: AppBar(
        elevation: 0.5, // Sedikit lebih tipis bayangannya
        backgroundColor: WarnaTema.softGrey,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset("assets/gambar/logo.png", height: 50),
            const SizedBox(width: 10),
            const Spacer(),
            const Text(
              "NakaMerch",
              style: TextStyle(
                fontSize: 22,
                color: WarnaTema.oceanBlue,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // --- BODY ---
      body: FutureBuilder<List<Produk>>(
        future: _daftarProduk,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Gagal memuat data 😢",
                style: TextStyle(color: WarnaTema.strawHatRed),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada produk ditemukan."));
          }

          var produkList = snapshot.data!;

          // Filter Search
          if (searchQuery.isNotEmpty) {
            produkList = produkList
                .where(
                  (p) => p.namaProduk.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
                )
                .toList();
          }

          // Filter Harga
          produkList = produkList.where((p) => p.harga <= hargaMax).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Greeting
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Hai, selamat datang di NakaMerch ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: WarnaTema.pirateBlack,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- SEARCH & FILTER BAR ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Search Bar
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 50, // Tinggi fix agar sejajar dengan dropdown
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: "Cari produk...",
                              prefixIcon: const Icon(Icons.search, size: 20),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (v) {
                              setState(() => searchQuery = v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Filter Harga Dropdown
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 50,
                          child: DropdownButtonFormField<double>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            initialValue: hargaMax,
                            icon: const Icon(Icons.filter_list, size: 20),
                            isExpanded: true, // Agar teks tidak overflow
                            items: const [
                              DropdownMenuItem(
                                value: 50000,
                                child: Text(
                                  "Under 50K",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 100000,
                                child: Text(
                                  "< 100K",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 300000,
                                child: Text(
                                  "< 300K",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 500000,
                                child: Text(
                                  "< 500K",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 999999999,
                                child: Text(
                                  "Semua",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() => hargaMax = v!);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- DAFTAR BRAND (Dynamic Lists) ---
                ..._buildBrandSections(produkList),

                // Tambahan space bawah agar tidak mentok
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
