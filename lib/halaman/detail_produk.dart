import 'package:flutter/material.dart';
import '../tema/warna.dart';
import '../layanan/api_produk.dart';
import '../layanan/local_service.dart';
import '../layanan/keranjang_item.dart';
import 'keranjang.dart';
import 'login.dart';

class DetailProduk extends StatefulWidget {
  final Produk produk;
  const DetailProduk({super.key, required this.produk});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  static const double _idrPerUsd = 15500.0;
  static const double _idrPerJpy = 110.0;

  String selectedCurrency = "IDR";

  // --- LOGIC (TIDAK DIUBAH SAMA SEKALI) ---
  String _formatPrice(int harga) {
    final double idr = harga.toDouble();
    if (selectedCurrency == "USD") {
      return "\$${(idr / _idrPerUsd).toStringAsFixed(2)}";
    } else if (selectedCurrency == "JPY") {
      return "¥${(idr / _idrPerJpy).toStringAsFixed(0)}";
    }
    return "Rp ${idr.toStringAsFixed(0)}";
  }

  Future<bool> _ensureLoggedIn() async {
    final isLogin = await LocalService.isLoggedIn();
    if (isLogin) return true;

    if (!mounted) return false;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(returnResult: true)),
    );

    if (result == true) return true;
    return await LocalService.isLoggedIn();
  }

  Future<void> _addToCart(int qty) async {
    final item = KeranjangItem(
      nama: widget.produk.namaProduk,
      gambar: widget.produk.gambar,
      jumlah: qty,
      harga: widget.produk.harga.toDouble(),
      kolaborasi: widget.produk.kolaborasi,
      dipilih: true,
      lokasi: widget.produk.lokasi,
    );

    await LocalService.addToKeranjang(item);
  }

  Future<void> _showQtyModal({required bool goToCart}) async {
    if (!(await _ensureLoggedIn())) return;

    int jumlah = 1;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => StatefulBuilder(
        builder: (_, setStateModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar Kecil
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Text(
                "Mau beli berapa?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: WarnaTema.pirateBlack,
                ),
              ),
              const SizedBox(height: 24),

              // Counter Qty
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 32,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: jumlah > 1 ? WarnaTema.pirateBlack : Colors.grey,
                    ),
                    onPressed: () {
                      if (jumlah > 1) setStateModal(() => jumlah--);
                    },
                  ),
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      "$jumlah",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: WarnaTema.pirateBlack,
                    ),
                    onPressed: () => setStateModal(() => jumlah++),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: WarnaTema.pirateBlack),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await _addToCart(jumlah);
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Berhasil masuk keranjang ✅"),
                            ),
                          );
                        },
                        child: const Text(
                          "Keranjang",
                          style: TextStyle(color: WarnaTema.pirateBlack),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WarnaTema.oceanBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await _addToCart(jumlah);
                          if (!mounted) return;
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KeranjangScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Beli Sekarang",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAMPILAN UTAMA (PROFESIONAL) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaTema.softGrey,

      // 1. Header Konsisten (AppBar)
      appBar: AppBar(
        backgroundColor: WarnaTema.softGrey,
        elevation: 0,
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
        title: const Text(
          "Detail Produk",
          style: TextStyle(
            color: WarnaTema.pirateBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
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

      // 2. Konten Scrollable
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk (Card Style)
            Hero(
              // Animasi halus saat transisi
              tag: widget.produk.gambar,
              child: Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: WarnaTema.skyWhite,
                  image: DecorationImage(
                    image: NetworkImage(widget.produk.gambar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Badge Kolaborasi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: WarnaTema.oceanBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${widget.produk.kolaborasi} Original",
                style: const TextStyle(
                  color: WarnaTema.oceanBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Judul Produk
            Text(
              widget.produk.namaProduk,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: WarnaTema.pirateBlack,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            // Lokasi
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.produk.lokasi,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // Harga & Currency Converter (Clean UI)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Harga",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      _formatPrice(widget.produk.harga),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: WarnaTema.pirateBlack,
                      ),
                    ),
                  ],
                ),

                // Dropdown yang lebih rapi
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCurrency,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      style: const TextStyle(
                        color: WarnaTema.pirateBlack,
                        fontWeight: FontWeight.bold,
                      ),
                      items: const [
                        DropdownMenuItem(value: "IDR", child: Text("IDR 🇮🇩")),
                        DropdownMenuItem(value: "USD", child: Text("USD 🇺🇸")),
                        DropdownMenuItem(value: "JPY", child: Text("JPY 🇯🇵")),
                      ],
                      onChanged: (v) => setState(() => selectedCurrency = v!),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Deskripsi
            const Text(
              "Deskripsi Produk",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: WarnaTema.pirateBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.produk.deskripsi,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(
              height: 100,
            ), // Space agar tidak tertutup tombol bawah
          ],
        ),
      ),

      // 3. Bottom Bar Fixed (Melayang di bawah)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WarnaTema.softGrey,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          // Aman untuk HP poni/home indicator
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: WarnaTema.pirateBlack),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _showQtyModal(goToCart: false),
                    child: const Text(
                      "+ Keranjang",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: WarnaTema.pirateBlack,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaTema.oceanBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _showQtyModal(goToCart: true),
                    child: const Text(
                      "Beli Sekarang",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
