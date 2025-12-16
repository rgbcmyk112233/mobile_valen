import 'package:flutter/material.dart';
import '../tema/warna.dart';

class SaranKesanPage extends StatefulWidget {
  const SaranKesanPage({super.key});

  @override
  State<SaranKesanPage> createState() => _SaranKesanPageState();
}

class _SaranKesanPageState extends State<SaranKesanPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isUnlocked = false;
  String _errorText = "";

  // Password terenkripsi (hasil Caesar Cipher shift 3 dari "MOBILEASIK")
  final String _encryptedPassword = "PRELOHDVLN";

  // Fungsi Caesar Cipher enkripsi (geser 3 huruf)
  String _encryptCaesar(String text, int shift) {
    return String.fromCharCodes(text.codeUnits.map((c) {
      if (c >= 65 && c <= 90) {
        // Huruf besar
        return ((c - 65 + shift) % 26) + 65;
      } else if (c >= 97 && c <= 122) {
        // Huruf kecil
        return ((c - 97 + shift) % 26) + 97;
      } else {
        return c;
      }
    }));
  }

  // Fungsi untuk verifikasi password (dekripsi lalu bandingkan)
  bool _verifyPassword(String input) {
    final encryptedInput = _encryptCaesar(input.toUpperCase(), 3);
    return encryptedInput == _encryptedPassword;
  }

  final List<Map<String, String>> _pesanDosen = const [
    {
      "nama": "Pak Andi",
      "saran": "Sangat sabar dan jelas dalam menjelaskan materi.",
      "kesan": "Membuat suasana kelas nyaman dan produktif."
    },
    {
      "nama": "Bu Sinta",
      "saran": "Memberikan banyak studi kasus menarik.",
      "kesan": "Membantu memahami konsep kompleks dengan mudah."
    },
    {
      "nama": "Pak Rudi",
      "saran": "Lebih sering beri contoh praktikum biar makin paham.",
      "kesan": "Asik dan terbuka dalam diskusi."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaTema.skyWhite,
      appBar: AppBar(
        title: const Text(
          "Saran & Kesan Dosen",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: WarnaTema.oceanBlue,
        centerTitle: true,
      ),
      body: !_isUnlocked ? _buildPasswordScreen() : _buildContentScreen(),
    );
  }

  Widget _buildPasswordScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "🔐 Masukkan Password untuk Melihat Saran & Kesan",
            style: TextStyle(
              color: WarnaTema.pirateBlack,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorText: _errorText.isEmpty ? null : _errorText,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaTema.oceanBlue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final input = _passwordController.text.trim();
              if (_verifyPassword(input)) {
                setState(() {
                  _isUnlocked = true;
                  _errorText = "";
                });
              } else {
                setState(() {
                  _errorText = "Password salah. Coba lagi.";
                });
              }
            },
            child: const Text(
              "Buka Halaman",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentScreen() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pesanDosen.length,
      itemBuilder: (context, index) {
        final data = _pesanDosen[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["nama"]!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: WarnaTema.oceanBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Saran: ${data["saran"]}"),
                Text("Kesan: ${data["kesan"]}"),
              ],
            ),
          ),
        );
      },
    );
  }
}
