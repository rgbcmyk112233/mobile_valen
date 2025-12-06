import 'dart:io';
import 'package:flutter/foundation.dart'; // ✅ Wajib untuk cek Web/Mobile
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../tema/warna.dart';
import 'login.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String namaUser = "";
  String emailUser = "";
  String passwordUser = "";
  String? imagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      namaUser = prefs.getString('logged_name') ?? "Nama Pengguna";
      emailUser = prefs.getString('logged_email') ?? "email@example.com";
      passwordUser = prefs.getString('logged_pass') ?? "password123";
      imagePath = prefs.getString('logged_image');
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_name', namaUser);
    await prefs.setString('logged_pass', passwordUser);
    if (imagePath != null) await prefs.setString('logged_image', imagePath!);
  }

  Future<void> _ubahFotoProfil() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imagePath = picked.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_image', picked.path);
    }
  }

  // ✅ SOLUSI ERROR WEB: Cek platform sebelum render gambar
  ImageProvider? _getImageProvider() {
    if (imagePath == null) return null;

    if (kIsWeb) {
      // Jika di Web, gunakan NetworkImage (blob url)
      return NetworkImage(imagePath!);
    } else {
      // Jika di Android/iOS, gunakan FileImage
      return FileImage(File(imagePath!));
    }
  }

  // ✅ EDIT PROFIL GABUNGAN (Nama & Password)
  void _editProfilDialog() {
    final namaCtrl = TextEditingController(text: namaUser);
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informasi Dasar",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),

              const Divider(),
              const SizedBox(height: 10),

              const Text(
                "Ubah Password (Opsional)",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(
                  labelText: "Password Baru",
                  hintText: "Kosongkan jika tidak diubah",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                decoration: const InputDecoration(
                  labelText: "Konfirmasi Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaTema.oceanBlue,
            ),
            onPressed: () {
              // 1. Validasi Nama
              if (namaCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nama tidak boleh kosong")),
                );
                return;
              }

              // 2. Validasi Password (Hanya jika diisi)
              if (passCtrl.text.isNotEmpty) {
                if (passCtrl.text != confirmCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Konfirmasi password tidak sama"),
                    ),
                  );
                  return;
                }
                // Update password state
                setState(() => passwordUser = passCtrl.text);
              }

              // 3. Simpan Data
              setState(() => namaUser = namaCtrl.text);
              _saveUserData();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profil berhasil diperbarui")),
              );
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaTema.softGrey,

      // HEADER
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(
            color: WarnaTema.pirateBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,

        // ✅ TOMBOL EDIT TUNGGAL DI POJOK KANAN ATAS
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: WarnaTema.pirateBlack),
            onPressed: _editProfilDialog,
            tooltip: "Edit Profil & Password",
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- KARTU FOTO & IDENTITAS ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: WarnaTema.oceanBlue.withOpacity(0.2),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _getImageProvider(),
                          child: imagePath == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[400],
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _ubahFotoProfil,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: WarnaTema.oceanBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    namaUser,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: WarnaTema.pirateBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emailUser,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- KARTU INFORMASI AKUN ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoTile(
                    icon: Icons.person_outline,
                    title: "Nama Lengkap",
                    value: namaUser,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  _infoTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    value: emailUser,
                    isReadOnly: true,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // Password disamarkan, editnya lewat tombol di atas
                  _infoTile(
                    icon: Icons.lock_outline,
                    title: "Password",
                    value: "••••••••••",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- KARTU KESAN & SARAN ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kesan & Saran",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: WarnaTema.pirateBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.thumb_up_alt_outlined,
                        size: 20,
                        color: WarnaTema.oceanBlue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Belajar Flutter banyak tantangannya tapi juga seru banget!",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Semoga makin banyak praktik dan studi kasus real.",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- TOMBOL LOGOUT ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Keluar Akun",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _logout,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget Info Baris (Tanpa Tombol Edit Internal)
  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WarnaTema.softGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: WarnaTema.oceanBlue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: WarnaTema.pirateBlack,
                  ),
                ),
              ],
            ),
          ),
          if (isReadOnly)
            const Icon(Icons.lock_outline, color: Colors.black12, size: 18),
        ],
      ),
    );
  }
}
