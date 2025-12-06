// lib/halaman/register.dart
import 'package:flutter/material.dart';
import '../layanan/auth_service.dart';
import '../tema/warna.dart'; // Pastikan import warna
import 'navbar.dart'; // Import navbar untuk navigasi setelah sukses

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final _auth = AuthService();
  bool loading = false;

  // --- LOGIKA REGISTER (TIDAK DIUBAH SECARA FUNGSIONAL) ---
  void _register() async {
    setState(() => loading = true);
    bool ok = await _auth.register(
      namaC.text.trim(),
      emailC.text.trim(),
      passC.text,
    );
    setState(() => loading = false);

    if (ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi berhasil! Selamat datang."),
          backgroundColor: WarnaTema.oceanBlue,
        ),
      );

      // Mengarahkan ke BottomNav (Halaman Utama) agar UX lebih mulus
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BottomNav()),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal daftar. Email mungkin sudah digunakan."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    namaC.dispose();
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  // --- TAMPILAN MINIMALIS SENADA LOGIN ---
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
              // 1. Tombol Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: WarnaTema.pirateBlack,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 2. Header
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/gambar/logo.png",
                      height: 70,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.person_add,
                        size: 70,
                        color: WarnaTema.oceanBlue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Buat Akun Baru",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: WarnaTema.pirateBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Lengkapi data diri untuk bergabung",
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 3. Form Input
              // Input Nama
              TextField(
                controller: namaC,
                decoration: InputDecoration(
                  hintText: "Nama Lengkap",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Colors.grey[500],
                  ),
                  filled: true,
                  fillColor: WarnaTema.softGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Input Email
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
                  fillColor: WarnaTema.softGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Input Password
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

              // 4. Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WarnaTema.oceanBlue,
                    elevation: 0,
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
                          "Daftar Sekarang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // 5. Link ke Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah punya akun? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Kembali ke Login
                    child: const Text(
                      "Masuk",
                      style: TextStyle(
                        color: WarnaTema.oceanBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
