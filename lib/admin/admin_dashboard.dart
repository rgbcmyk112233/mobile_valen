import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../tema/warna.dart';
import '../halaman/login.dart'; // Untuk logout admin

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allOrders = [];
  late TabController _tabController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  // 1. LOAD DATA DARI SHARED PREFERENCES (Sama dengan Riwayat User)
  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('riwayat_pesanan');
    if (data != null) {
      setState(() {
        allOrders = List<Map<String, dynamic>>.from(jsonDecode(data));
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // 2. SIMPAN PERUBAHAN STATUS
  Future<void> _updateOrderStatus(
    Map<String, dynamic> order,
    String newStatus,
  ) async {
    setState(() {
      order['status'] = newStatus;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('riwayat_pesanan', jsonEncode(allOrders));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status diperbarui menjadi: $newStatus")),
      );
    }
  }

  // 3. HAPUS PESANAN (Opsional Admin)
  Future<void> _deleteOrder(Map<String, dynamic> order) async {
    setState(() {
      allOrders.remove(order);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('riwayat_pesanan', jsonEncode(allOrders));
  }

  // Format Tanggal
  String _formatDate(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate);
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}";
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter List berdasarkan Status
    var pendingList = allOrders
        .where((e) => e['status'] == 'Diproses')
        .toList();
    var shippingList = allOrders
        .where((e) => e['status'] == 'Dikirim')
        .toList();
    var completedList = allOrders
        .where((e) => e['status'] == 'Selesai')
        .toList();

    return Scaffold(
      backgroundColor: WarnaTema.softGrey,

      // HEADER ADMIN
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: WarnaTema.pirateBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: WarnaTema.oceanBlue),
            onPressed: _loadOrders,
            tooltip: "Refresh Data",
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: WarnaTema.oceanBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: WarnaTema.oceanBlue,
          tabs: [
            Tab(child: Text("Masuk (${pendingList.length})")),
            Tab(child: Text("Dikirim (${shippingList.length})")),
            Tab(child: Text("Selesai (${completedList.length})")),
          ],
        ),
      ),

      // BODY
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(
                  pendingList,
                  "Belum ada pesanan masuk",
                  "process",
                ),
                _buildOrderList(
                  shippingList,
                  "Tidak ada pengiriman berjalan",
                  "shipping",
                ),
                _buildOrderList(
                  completedList,
                  "Belum ada riwayat selesai",
                  "done",
                ),
              ],
            ),
    );
  }

  Widget _buildOrderList(
    List<Map<String, dynamic>> orders,
    String emptyMsg,
    String type,
  ) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(emptyMsg, style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        final List items = order['items'] ?? [];

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
              // HEADER CARD
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(order['tanggal'] ?? ""),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => _deleteOrder(order),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // ALAMAT PENGIRIMAN
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Alamat Pengiriman:",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: WarnaTema.oceanBlue,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order['alamat'] ?? "Alamat tidak tersedia",
                            style: const TextStyle(
                              fontSize: 13,
                              color: WarnaTema.pirateBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // LIST ITEMS
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: items.map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              item['gambar'] ?? '',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey[200],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama'] ?? "-",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  "${item['jumlah']} x ${item['harga']}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
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

              // FOOTER (TOTAL & AKSI)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Tagihan",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          order['total'] ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: WarnaTema.oceanBlue,
                          ),
                        ),
                        Text(
                          order['pembayaran'] ?? "-",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    // TOMBOL AKSI (LOGIKA ADMIN)
                    if (type == 'process')
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WarnaTema.oceanBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(
                          Icons.local_shipping,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Kirim Barang",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => _updateOrderStatus(order, "Dikirim"),
                      )
                    else if (type == 'shipping')
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Selesaikan",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => _updateOrderStatus(order, "Selesai"),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.done_all, size: 16, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              "Selesai",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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
}
