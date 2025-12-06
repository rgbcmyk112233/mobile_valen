import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../tema/warna.dart';
import 'navbar.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> semuaPesanan = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _muatRiwayat();
  }

  Future<void> _muatRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('riwayat_pesanan');
    if (data != null) {
      setState(() {
        semuaPesanan = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  // Format Tanggal
  String _formatTanggal(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate);
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}";
    } catch (e) {
      return rawDate;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter Data per Status
    List<Map<String, dynamic>> listDiproses = semuaPesanan
        .where((e) => e['status'] == 'Diproses')
        .toList();
    List<Map<String, dynamic>> listDikirim = semuaPesanan
        .where((e) => e['status'] == 'Dikirim')
        .toList();
    List<Map<String, dynamic>> listSelesai = semuaPesanan
        .where((e) => e['status'] == 'Selesai')
        .toList();

    return Scaffold(
      backgroundColor: WarnaTema.softGrey,

      // HEADER
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: WarnaTema.pirateBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(
            color: WarnaTema.pirateBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: WarnaTema.pirateBlack),
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
        ],
        // TAB BAR MENU
        bottom: TabBar(
          controller: _tabController,
          labelColor: WarnaTema.oceanBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: WarnaTema.oceanBlue,
          tabs: const [
            Tab(text: "Diproses"),
            Tab(text: "Dikirim"),
            Tab(text: "Selesai"),
          ],
        ),
      ),

      // BODY: TAB VIEW
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListPesanan(listDiproses, "Belum ada pesanan diproses"),
          _buildListPesanan(listDikirim, "Belum ada pesanan dikirim"),
          _buildListPesanan(listSelesai, "Belum ada riwayat selesai"),
        ],
      ),
    );
  }

  Widget _buildListPesanan(List<Map<String, dynamic>> data, String emptyMsg) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(emptyMsg, style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final pesanan = data[index];
        final List items = pesanan['items'] ?? [];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Card (Tanggal & Label Status)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTanggal(pesanan['tanggal'] ?? ""),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    // Label Status (Hanya View)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          pesanan['status'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        pesanan['status'] ?? "-",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(pesanan['status']),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // 2. List Item Barang
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['gambar'] ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
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
                                  item['nama'] ?? "Produk",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  "${item['jumlah']} barang",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Divider(height: 1),

              // 3. Footer (Total Harga)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Belanja",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          pesanan['total'] ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: WarnaTema.pirateBlack,
                          ),
                        ),
                      ],
                    ),

                    // Info tambahan (Opsional, pengganti tombol admin)
                    if (pesanan['status'] == 'Diproses')
                      const Text(
                        "Menunggu Penjual",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else if (pesanan['status'] == 'Dikirim')
                      const Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 16,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Dalam Perjalanan",
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ],
                      )
                    else
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Transaksi Selesai",
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    if (status == 'Diproses') return Colors.orange;
    if (status == 'Dikirim') return Colors.blue;
    if (status == 'Selesai') return Colors.green;
    return Colors.grey;
  }
}
