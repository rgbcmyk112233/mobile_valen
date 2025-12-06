import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LayananLokasi {
  // Minta izin lokasi
  static Future<bool> mintaIzinLokasi() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false; // Layanan GPS belum aktif
    }

    // Cek izin aplikasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // Pengguna menolak permanen
    }

    return true;
  }

  // Ambil lokasi sekarang
  static Future<Position?> ambilLokasiSekarang() async {
    try {
      bool izin = await mintaIzinLokasi();
      if (!izin) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("❌ Gagal ambil lokasi: $e");
      return null;
    }
  }

  // Ubah koordinat ke nama lokasi
  static Future<String> ambilNamaLokasi(Position posisi) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        posisi.latitude,
        posisi.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.subAdministrativeArea ?? ''}, ${place.administrativeArea ?? ''}";
      } else {
        return "Lokasi tidak ditemukan";
      }
    } catch (e) {
      print("❌ Gagal ambil nama lokasi: $e");
      return "Lokasi tidak diketahui";
    }
  }
}
