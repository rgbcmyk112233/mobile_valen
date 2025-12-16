// lib/halaman/notifikasi.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../tema/warna.dart'; // Pastikan path warna benar

// ==========================================================
// BAGIAN 1: SERVICE (LOGIKA MEMUNCULKAN NOTIFIKASI)
// ==========================================================
class NotifikasiService {
  static final NotifikasiService _instance = NotifikasiService._internal();
  factory NotifikasiService() => _instance;
  NotifikasiService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Inisialisasi (Dipanggil sekali di main.dart)
  Future<void> init() async {
    // Icon bawaan flutter biasanya '@mipmap/ic_launcher'
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings);
  }

  // Fungsi untuk memanggil Notifikasi Checkout
  Future<void> tampilkanNotifikasiCheckout() async {
    const androidDetails = AndroidNotificationDetails(
      'channel_checkout', // ID Channel
      'Checkout & Pembayaran', // Nama Channel
      channelDescription: 'Notifikasi instruksi pembayaran',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      0, // ID Notifikasi
      'Checkout Berhasil! 🛒', // JUDUL
      'Segera transfer Rp 150.000 ke BCA 123456 a.n NakaMerch.', // ISI PESAN
      details,
    );
  }
}

// ==========================================================
// BAGIAN 2: SCREEN (TAMPILAN HALAMAN NOTIFIKASI)
// ==========================================================
class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: WarnaTema.oceanBlue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "Belum ada riwayat notifikasi",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            // Tombol Test (Opsional, buat ngecek aja)
            ElevatedButton(
              onPressed: () {
                NotifikasiService().tampilkanNotifikasiCheckout();
              },
              child: const Text("Test Munculkan Notifikasi"),
            ),
          ],
        ),
      ),
    );
  }
}