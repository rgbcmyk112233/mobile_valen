// lib/halaman/checkout.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tema/warna.dart';
import '../layanan/keranjang_item.dart';
import 'riwayat.dart';
import 'notifikasi.dart'; // <--- 1. IMPORT NOTIFIKASI DISINI

class CheckoutScreen extends StatefulWidget {
  final List<KeranjangItem> items;
  final String selectedCurrency;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.selectedCurrency,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // --- STATE ALAMAT ---
  String negara = "Indonesia";
  String? provinsi;
  String? kota;
  String jalan = "";

  // State Logika Pengiriman
  String zonaWaktu = "WIB";
  Duration offsetWaktu = const Duration(hours: 7);
  int estimasiHariMin = 2;
  int estimasiHariMax = 4;

  String metodePembayaran = "Transfer Bank";

  // --- DATA WILAYAH ---
  final Map<String, List<String>> countryMap = {
    "Indonesia": [
      "DKI Jakarta",
      "Jawa Barat",
      "Jawa Tengah",
      "Jawa Timur",
      "Bali",
      "Sulawesi Selatan",
      "Papua",
    ],
    "United Kingdom": ["England", "Scotland"],
    "Japan": ["Tokyo Prefecture", "Osaka Prefecture"],
  };

  final Map<String, List<String>> cityMap = {
    "DKI Jakarta": ["Jakarta Selatan", "Jakarta Pusat"],
    "Jawa Barat": ["Bandung", "Bekasi", "Depok"],
    "Jawa Tengah": ["Semarang", "Solo"],
    "Jawa Timur": ["Surabaya", "Malang"],
    "Bali": ["Denpasar", "Badung"],
    "Sulawesi Selatan": ["Makassar"],
    "Papua": ["Jayapura", "Merauke"],
    "England": ["London", "Manchester"],
    "Scotland": ["Edinburgh"],
    "Tokyo Prefecture": ["Shinjuku", "Shibuya"],
    "Osaka Prefecture": ["Osaka City"],
  };

  static const double _idrPerUsd = 15500.0;
  static const double _idrPerJpy = 110.0;

  @override
  void initState() {
    super.initState();
    provinsi = "DKI Jakarta";
    kota = "Jakarta Selatan";

    // Update logika setelah build pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateShippingLogic();
    });
  }

  // ✅ 1. AMBIL LOKASI REAL DARI DATA (TANPA HARDCODE NEGARA)
  String _getOriginLocation() {
    final locations = widget.items
        .map((e) => e.lokasi ?? "Jakarta")
        .toSet()
        .toList();

    if (locations.isEmpty) return "Jakarta";

    if (locations.length == 1) {
      return locations.first;
    } else {
      return "Berbagai Gudang";
    }
  }

  // ✅ 2. LOGIKA PENGIRIMAN
  void _updateShippingLogic() {
    String asalBarang = _getOriginLocation();

    setState(() {
      // A. Tentukan Zona Waktu Tujuan
      if (negara == "Indonesia") {
        if (["Bali", "Sulawesi Selatan"].contains(provinsi)) {
          zonaWaktu = "WITA";
          offsetWaktu = const Duration(hours: 8);
        } else if (["Papua"].contains(provinsi)) {
          zonaWaktu = "WIT";
          offsetWaktu = const Duration(hours: 9);
        } else {
          zonaWaktu = "WIB";
          offsetWaktu = const Duration(hours: 7);
        }
      } else if (negara == "Japan") {
        zonaWaktu = "JST";
        offsetWaktu = const Duration(hours: 9);
      } else if (negara == "United Kingdom") {
        zonaWaktu = "GMT";
        offsetWaktu = const Duration(hours: 0);
      }

      // B. Logika Estimasi Hari
      bool isDomestic = asalBarang.toLowerCase().contains(negara.toLowerCase());

      if (negara == "Indonesia" &&
          (asalBarang.contains("Jakarta") || asalBarang.contains("Bandung"))) {
        isDomestic = true;
      }

      if (isDomestic) {
        bool sameCity = asalBarang.toLowerCase().contains(
          (kota ?? "").toLowerCase(),
        );

        if (sameCity) {
          estimasiHariMin = 1;
          estimasiHariMax = 2;
        } else {
          estimasiHariMin = 2;
          estimasiHariMax = 4;

          if (negara == "Indonesia" &&
              ["Papua", "Sulawesi Selatan"].contains(provinsi)) {
            estimasiHariMin = 4;
            estimasiHariMax = 7;
          }
        }
      } else {
        estimasiHariMin = 7;
        estimasiHariMax = 14;
      }
    });
  }

  String _format(double idrValue) {
    if (widget.selectedCurrency == "USD") {
      return "\$${(idrValue / _idrPerUsd).toStringAsFixed(2)}";
    } else if (widget.selectedCurrency == "JPY") {
      return "¥${(idrValue / _idrPerJpy).toStringAsFixed(0)}";
    }
    return "Rp ${idrValue.toStringAsFixed(0)}";
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    DateTime utcNow = DateTime.now().toUtc();
    DateTime localTime = utcNow.add(offsetWaktu);
    DateTime minArrival = localTime.add(Duration(days: estimasiHariMin));
    DateTime maxArrival = localTime.add(Duration(days: estimasiHariMax));

    String jamLokal =
        "${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}";
    String estimasiSampai =
        "${_formatDate(minArrival)} - ${_formatDate(maxArrival)}";

    String dikirimDari = _getOriginLocation();

    return Scaffold(
      backgroundColor: WarnaTema.softGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
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
        title: const Text(
          "Pengiriman",
          style: TextStyle(
            color: WarnaTema.pirateBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Alamat Tujuan", Icons.location_on_outlined),
                  _buildAddressForm(),
                  const SizedBox(height: 20),
                  _sectionTitle(
                    "Info Pengiriman",
                    Icons.local_shipping_outlined,
                  ),
                  _buildShippingInfo(jamLokal, estimasiSampai, dikirimDari),
                  const SizedBox(height: 20),
                  _sectionTitle("Daftar Pesanan", Icons.shopping_bag_outlined),
                  _buildOrderSummary(),
                  const SizedBox(height: 20),
                  _sectionTitle("Pembayaran", Icons.payment),
                  _buildPaymentMethod(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: WarnaTema.oceanBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: WarnaTema.pirateBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLabeledInput(String label, Widget inputField) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        inputField,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAddressForm() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledInput(
            "Negara",
            DropdownButtonFormField<String>(
              decoration: _inputDecoration(),
              initialValue: negara,
              isExpanded: true,
              items: countryMap.keys
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  negara = v!;
                  provinsi = null;
                  kota = null;
                  _updateShippingLogic();
                });
              },
            ),
          ),
          _buildLabeledInput(
            "Provinsi / Wilayah",
            DropdownButtonFormField<String>(
              decoration: _inputDecoration(hint: "Pilih Wilayah"),
              initialValue: provinsi,
              isExpanded: true,
              items: (countryMap[negara] ?? [])
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  provinsi = v;
                  kota = null;
                  _updateShippingLogic();
                });
              },
            ),
          ),
          _buildLabeledInput(
            "Kota / Distrik",
            DropdownButtonFormField<String>(
              decoration: _inputDecoration(hint: "Pilih Kota"),
              initialValue: kota,
              isExpanded: true,
              items: (cityMap[provinsi] ?? [])
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => kota = v),
            ),
          ),
          _buildLabeledInput(
            "Detail Jalan",
            TextFormField(
              decoration: _inputDecoration(hint: "Nama Jalan, No. Rumah"),
              onChanged: (v) => jalan = v,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: WarnaTema.softGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WarnaTema.oceanBlue, width: 1),
      ),
    );
  }

  Widget _buildShippingInfo(
    String jamLokal,
    String rentangSampai,
    String asalBarang,
  ) {
    return _buildCard(
      child: Column(
        children: [
          _infoRow("Dikirim Dari", asalBarang),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1, thickness: 0.5),
          ),
          _infoRow("Zona Waktu Tujuan", zonaWaktu, isHighlight: true),
          const SizedBox(height: 6),
          _infoRow("Waktu Lokal", jamLokal),
          const SizedBox(height: 6),
          _infoRow("Estimasi Tiba", rentangSampai, isHighlight: true),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "($estimasiHariMin - $estimasiHariMax Hari Kerja)",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
            color: isHighlight ? WarnaTema.oceanBlue : WarnaTema.pirateBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return _buildCard(
      child: Column(
        children: widget.items.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    e.gambar,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(
                      width: 50,
                      height: 50,
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
                        e.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "${e.jumlah} barang",
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  _format(e.harga * e.jumlah.toDouble()),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: WarnaTema.oceanBlue,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return _buildCard(
      child: Column(
        children: [
          _radioTile("Transfer Bank"),
          const Divider(height: 1, thickness: 0.5),
          _radioTile("Cash on Delivery (COD)"),
        ],
      ),
    );
  }

  Widget _radioTile(String value) {
    return RadioListTile<String>(
      title: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      value: value,
      activeColor: WarnaTema.oceanBlue,
      dense: true,
      contentPadding: EdgeInsets.zero,
      groupValue: metodePembayaran,
      onChanged: (v) => setState(() => metodePembayaran = v ?? value),
    );
  }

  Widget _buildBottomBar() {
    double total = widget.items.fold(0, (t, e) => t + (e.harga * e.jumlah));

    return Container(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Tagihan",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _format(total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: WarnaTema.pirateBlack,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WarnaTema.oceanBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final data = prefs.getString('riwayat_pesanan');
                List<Map<String, dynamic>> list = data != null
                    ? List<Map<String, dynamic>>.from(jsonDecode(data))
                    : [];

                list.add({
                  "items": widget.items
                      .map(
                        (e) => {
                          "nama": e.nama,
                          "kolaborasi": e.kolaborasi ?? "-",
                          "jumlah": e.jumlah,
                          "harga": e.harga,
                          "gambar": e.gambar,
                        },
                      )
                      .toList(),
                  "total": _format(total),
                  "pembayaran": metodePembayaran,
                  "status": "Diproses",
                  "alamat": "$kota, $provinsi, $negara",
                  "tanggal": DateTime.now().toString(),
                });

                await prefs.setString('riwayat_pesanan', jsonEncode(list));

                // --- 2. LOGIKA NOTIFIKASI DISINI ---
                // Memunculkan notifikasi "Ting!" di HP
                await NotifikasiService().tampilkanNotifikasiCheckout();
                // ------------------------------------

                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RiwayatScreen()),
                  );
                }
              },
              child: const Text(
                "Bayar Sekarang",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
