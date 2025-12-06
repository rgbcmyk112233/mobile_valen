// lib/halaman/notifikasi.dart
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../tema/warna.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  late FirebaseMessaging _messaging;
  String _notification = "Belum ada notifikasi";

  @override
  void initState() {
    super.initState();
    _messaging = FirebaseMessaging.instance;
    _requestPermission();
    _initFCM();
    _listenFCM();
  }

  void _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  void _initFCM() async {
    String? token = await _messaging.getToken();
    debugPrint("FCM Token: $token");
    // Kirim token ke backend agar server bisa push notif ke device ini
  }

  void _listenFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _notification = message.notification?.title ?? "Judul tidak ada";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_notification)),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.pushNamed(context, '/detailNotifikasi');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Ini akan dijalankan saat app di background / terminated
    debugPrint("Handling a background message: ${message.messageId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Produk Baru'),
        backgroundColor: WarnaTema.oceanBlue,
      ),
      body: Center(
        child: Text(_notification),
      ),
    );
  }
}
