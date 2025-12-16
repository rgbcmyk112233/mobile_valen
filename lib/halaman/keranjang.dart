import 'package:flutter/material.dart';
import '../tema/warna.dart';
import '../layanan/local_service.dart';
import '../layanan/keranjang_item.dart';
import 'checkout.dart';
import 'navbar.dart';
import 'beranda.dart';

class KeranjangScreen extends StatefulWidget {
  final bool isFromNavbar; // ✅ Parameter baru

  // Default false, jadi kalau dipanggil dari DetailProduk, tombol back tetap ada
  const KeranjangScreen({super.key, this.isFromNavbar = false});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  List<KeranjangItem> keranjang = [];
  bool isLoading = true;
  String selectedCurrency = "IDR";
  static const double _idrPerUsd = 15500.0;
  static const double _idrPerJpy = 110.0;

  @override
  void initState() {
    super.initState();
    _loadKeranjang();
  }

  Future<void> _loadKeranjang() async {
    final items = await LocalService.loadKeranjang();
    if (!widget.isFromNavbar) {
      // Reset pilihan hanya jika bukan dari tab (opsional)
      for (var item in items) {
        item.dipilih = false;
      }
    }
    setState(() {
      keranjang = items;
      isLoading = false;
    });
    // updateStorage(); // Opsional: jangan update storage di init jika hanya view
  }

  Future<void> updateStorage() async {
    await LocalService.saveKeranjang(keranjang);
  }

  double convert(double idr) {
    if (selectedCurrency == "USD") return idr / _idrPerUsd;
    if (selectedCurrency == "JPY") return idr / _idrPerJpy;
    return idr;
  }

  String format(double idr) {
    if (selectedCurrency == "USD") {
      return "\$${convert(idr).toStringAsFixed(2)}";
    }
    if (selectedCurrency == "JPY") return "¥${convert(idr).toStringAsFixed(0)}";
    return "Rp ${idr.toStringAsFixed(0)}";
  }

  double getTotal() => keranjang
      .where((e) => e.dipilih)
      .fold(0, (t, e) => t + (e.harga * e.jumlah));

  Map<String, List<KeranjangItem>> get groupedItems {
    Map<String, List<KeranjangItem>> groups = {};
    for (var item in keranjang) {
      String brand = item.kolaborasi ?? "Lainnya";
      if (!groups.containsKey(brand)) groups[brand] = [];
      groups[brand]!.add(item);
    }
    return groups;
  }

  void _toggleBrand(String brand, bool? value) {
    setState(() {
      final items = groupedItems[brand] ?? [];
      for (var item in items) {
        item.dipilih = value ?? false;
      }
    });
    updateStorage();
  }

  @override
  Widget build(BuildContext context) {
    final groups = groupedItems;
    final brands = groups.keys.toList();

    return Scaffold(
      backgroundColor: WarnaTema.softGrey,

      // ✅ APPBAR DINAMIS
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        // Jika dari Navbar, jangan kasih tombol Back (null)
        leading: widget.isFromNavbar
            ? null
            : Padding(
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
        // Matikan default back button flutter
        automaticallyImplyLeading: false,

        title: const Text(
          "Keranjang",
          style: TextStyle(
            color: WarnaTema.pirateBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        // Jika dari Navbar, jangan tampilkan Action Home
        actions: widget.isFromNavbar
            ? []
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.home_rounded,
                      color: WarnaTema.pirateBlack,
                      size: 26,
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BottomNav(initialIndex: 0),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : keranjang.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Keranjang masih kosong",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: brands.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final brand = brands[i];
                final itemsInBrand = groups[brand]!;
                bool isBrandSelected = itemsInBrand.every(
                  (item) => item.dipilih,
                );

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              activeColor: WarnaTema.oceanBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              value: isBrandSelected,
                              onChanged: (val) => _toggleBrand(brand, val),
                            ),
                            const Icon(
                              Icons.storefront,
                              size: 20,
                              color: WarnaTema.pirateBlack,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              brand,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: WarnaTema.pirateBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 0.5),
                      ...itemsInBrand.map((item) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Transform.scale(
                                scale: 1.1,
                                child: Checkbox(
                                  activeColor: WarnaTema.oceanBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  value: item.dipilih,
                                  onChanged: (v) {
                                    setState(() => item.dipilih = v!);
                                    updateStorage();
                                  },
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.gambar,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey[200],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.nama,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      format(item.harga),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: WarnaTema.oceanBlue,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            setState(
                                              () => keranjang.remove(item),
                                            );
                                            await updateStorage();
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.delete_outline,
                                              size: 20,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: WarnaTema.softGrey,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                iconSize: 16,
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.remove),
                                                onPressed: () async {
                                                  if (item.jumlah > 1) {
                                                    setState(
                                                      () => item.jumlah--,
                                                    );
                                                  } else {
                                                    setState(
                                                      () => keranjang.remove(
                                                        item,
                                                      ),
                                                    );
                                                  }
                                                  await updateStorage();
                                                },
                                              ),
                                              Text(
                                                "${item.jumlah}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                iconSize: 16,
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.add),
                                                onPressed: () async {
                                                  setState(() => item.jumlah++);
                                                  await updateStorage();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),

      bottomNavigationBar: widget.isFromNavbar && getTotal() == 0
          ? null // Opsional: Sembunyikan bottom bar di navbar jika kosong (pilihan desain)
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCurrency,
                            icon: const Icon(
                              Icons.expand_more,
                              color: Colors.grey,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: WarnaTema.pirateBlack,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "IDR",
                                child: Text("IDR 🇮🇩"),
                              ),
                              DropdownMenuItem(
                                value: "USD",
                                child: Text("USD 🇺🇸"),
                              ),
                              DropdownMenuItem(
                                value: "JPY",
                                child: Text("JPY 🇯🇵"),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => selectedCurrency = v!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 7,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WarnaTema.oceanBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: getTotal() == 0
                              ? () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Pilih produk dulu ya! 😄",
                                        ),
                                      ),
                                    )
                              : () {
                                  final selected = keranjang
                                      .where((e) => e.dipilih)
                                      .toList();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CheckoutScreen(
                                        items: selected,
                                        selectedCurrency: selectedCurrency,
                                      ),
                                    ),
                                  );
                                },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Checkout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  "(${format(getTotal())})",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
