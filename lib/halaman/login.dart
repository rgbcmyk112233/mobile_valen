// lib/halaman/login.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../layanan/auth_service.dart';
import '../layanan/local_service.dart';
import '../tema/warna.dart';
import 'navbar.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  final bool returnResult;

  const LoginScreen({super.key, this.returnResult = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final _auth = AuthService();
  bool loading = false;

  // --- LOGIKA (TIDAK DIUBAH) ---
  void _login() async {
    setState(() => loading = true);

    bool ok = await _auth.login(emailC.text.trim(), passC.text.trim());

    setState(() => loading = false);

    if (ok) {
      await LocalService.loginUser(emailC.text.trim());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_email', emailC.text.trim());
      await prefs.setString(
        'logged_name',
        _ambilNamaDariEmail(emailC.text.trim()),
      );
      await prefs.setString('logged_phone', 'Belum diisi');

      if (widget.returnResult) {
        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BottomNav()),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email atau password salah"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _ambilNamaDariEmail(String email) {
    if (email.contains('@')) {
      return email.split('@')[0].replaceAll('.', ' ').toUpperCase();
    }
    return "Pengguna";
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  // --- TAMPILAN MINIMALIS ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tombol Back (Custom Minimalist)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Lingkaran abu-abu tipis
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: WarnaTema.pirateBlack,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 2. Header Logo & Teks
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/gambar/logo.png",
                      height: 70,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.storefront,
                        size: 70,
                        color: WarnaTema.oceanBlue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Selamat Datang!",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: WarnaTema.pirateBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Masuk untuk melanjutkan belanja",
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // 3. Form Input (Clean Style - Tanpa Label Atas)
              TextField(
                controller: emailC,
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey[500],
                  ),
                  filled: true,
                  fillColor: WarnaTema.softGrey, // Warna background input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none, // Hapus garis border
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passC,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
                  filled: true,
                  fillColor: WarnaTema.softGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 40),

              // 4. Tombol Login
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaTema.oceanBlue,
                    elevation: 0, // Flat design
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Masuk",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // 5. Link Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Belum punya akun? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text(
                      "Daftar",
                      style: TextStyle(
                        color: WarnaTema.oceanBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
