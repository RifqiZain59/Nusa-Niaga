import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class PusatbantuanController extends GetxController {
  // Nomor tujuan (Format 62...)
  final String adminWhatsApp = "+6282220179188";

  // Fungsi untuk mengirim pesan ke WhatsApp
  Future<void> hubungiWhatsApp() async {
    final String message = "Halo Admin Nusa Niaga, saya butuh bantuan.";

    // Menggunakan Uri yang lebih terstruktur
    final Uri whatsappUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: adminWhatsApp,
      queryParameters: {'text': message},
    );

    try {
      // Cek apakah aplikasi bisa dibuka
      bool launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication, // Membuka aplikasi WA langsung
      );

      if (!launched) {
        _showErrorSnackbar(
          "Gagal membuka WhatsApp. Pastikan aplikasi terpasang.",
        );
      }
    } catch (e) {
      _showErrorSnackbar("Terjadi kesalahan: $e");
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Pusat Bantuan",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }
}
