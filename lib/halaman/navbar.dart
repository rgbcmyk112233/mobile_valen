import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tema/warna.dart';
import 'beranda.dart';
import 'keranjang.dart';
import 'riwayat.dart';
import 'profil.dart';
import 'login.dart';

class BottomNav extends StatefulWidget {
  final int initialIndex; // ✅ Tambahkan ini agar bisa diatur dari luar

  const BottomNav({super.key, this.initialIndex = 0}); // Default ke 0 (Beranda)

  @override
  State<BottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<BottomNav> {
  late int _currentIndex; // ✅ Ubah jadi late agar bisa di-init di initState
  String? _loggedEmail;

  // Halaman untuk user yang sudah login
  final List<Widget> _pagesLogged = const [
    BerandaScreen(),
    KeranjangScreen(),
    RiwayatScreen(),
    ProfilScreen(),
  ];

  // Halaman untuk guest (belum login)
  final List<Widget> _pagesGuest = const [
    BerandaScreen(),
    SizedBox(), // Placeholder
    SizedBox(), // Placeholder
    SizedBox(), // Placeholder
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // ✅ Set tab awal sesuai permintaan
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedEmail = prefs.getString('logged_email');
    });
  }

  void _onNavTap(int index) {
    // Dashboard selalu bisa dibuka
    if (index == 0) {
      setState(() => _currentIndex = index);
      return;
    }

    // Kalau belum login, arahkan ke halaman login
    if (_loggedEmail == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ).then((_) {
        // Cek login lagi setelah kembali dari halaman login
        _checkLogin();
      });
      return;
    }

    // Kalau sudah login, buka halaman sesuai index
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = _loggedEmail != null ? _pagesLogged : _pagesGuest;

    return Scaffold(
      backgroundColor: WarnaTema.softGrey,

      // Menampilkan halaman sesuai index saat ini
      body: pages[_currentIndex],

      bottomNavigationBar: Container(
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
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: WarnaTema.oceanBlue,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: _onNavTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: "Keranjang",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "Riwayat",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}
