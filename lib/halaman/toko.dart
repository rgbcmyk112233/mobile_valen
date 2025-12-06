import 'package:flutter/material.dart';
import '../tema/warna.dart';
import '../layanan/api_produk.dart';
import 'detail_produk.dart';
import 'keranjang.dart'; // ✅ Pastikan import ini ada untuk navigasi ke keranjang

class TokoScreen extends StatelessWidget {
  final String brand;
  const TokoScreen({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaTema.softGrey,

      // ✅ HEADER BARU (Back - Judul Brand - Keranjang)
      appBar: AppBar(
        backgroundColor: WarnaTema.softGrey,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: WarnaTema.pirateBlack,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          brand, // Menampilkan Nama Brand sebagai Judul
          style: const TextStyle(
            color: WarnaTema.pirateBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: WarnaTema.pirateBlack,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KeranjangScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ✅ BODY LANGSUNG LIST PRODUK (Tanpa header manual lagi)
      body: FutureBuilder<List<Produk>>(
        future: ApiProduk.ambilProduk(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          // Filter produk berdasarkan brand
          final list = snap.data!
              .where(
                (p) =>
                    (p.kolaborasi ?? '').toLowerCase() == brand.toLowerCase(),
              )
              .toList();

          // Tampilan jika kosong
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Belum ada produk untuk $brand",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Grid Produk
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7, // Rasio kartu agar muat info
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final p = list[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailProduk(produk: p)),
                  );
                },
                // Desain Kartu Produk
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar Produk
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            p.gambar,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                Container(color: Colors.grey[200]),
                          ),
                        ),
                      ),

                      // Info Produk
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.namaProduk,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: WarnaTema.pirateBlack,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rp ${p.harga}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: WarnaTema.pirateBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
