import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ionicons/ionicons.dart';

class LupapasswordController extends GetxController {
  // 1. Text Controller
  late TextEditingController emailC;

  // 2. Loading State
  var isLoading = false.obs;

  // Instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    emailC = TextEditingController();
  }

  @override
  void onClose() {
    emailC.dispose();
    super.onClose();
  }

  // 3. FUNGSI UTAMA: Kirim Reset Password
  Future<void> sendResetPasswordLink() async {
    String email = emailC.text.trim();

    // Validasi Input Kosong
    if (email.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Mohon masukkan alamat email Anda.",
        backgroundColor: Colors.amber[100],
        colorText: Colors.orange[900],
        icon: Icon(Ionicons.alert_circle, color: Colors.orange[900]),
      );
      return;
    }

    // Validasi Format Email
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Format Salah",
        "Format email tidak valid (contoh: nama@email.com)",
        backgroundColor: Colors.amber[100],
        colorText: Colors.orange[900],
        icon: Icon(Ionicons.warning, color: Colors.orange[900]),
      );
      return;
    }

    try {
      isLoading.value = true;

      // --- CORE LOGIC FIREBASE ---
      await _auth.sendPasswordResetEmail(email: email);
      // ---------------------------

      isLoading.value = false;

      // Tampilkan Dialog Sukses yang Informatif
      Get.defaultDialog(
        title: "Email Terkirim!",
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        content: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Ionicons.mail_unread,
                size: 40,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Link reset password telah dikirim ke:\n$email",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              "Silakan cek Inbox atau folder Spam Anda.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        confirm: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.back(); // Tutup Dialog
              Get.back(); // Kembali ke Login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB), // Primary Blue
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Kembali ke Login",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        radius: 16,
        contentPadding: const EdgeInsets.all(20),
      );

      // Bersihkan input
      emailC.clear();
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      String title = "Gagal Mengirim";
      String message = "Terjadi kesalahan sistem.";

      if (e.code == 'user-not-found') {
        title = "Email Tidak Ditemukan";
        message = "Email ini belum terdaftar di aplikasi kami.";
      } else if (e.code == 'invalid-email') {
        title = "Email Tidak Valid";
        message = "Format email yang Anda masukkan salah.";
      } else {
        message = e.message ?? "Gagal mengirim email reset.";
      }

      Get.snackbar(
        title,
        message,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        icon: Icon(Ionicons.close_circle, color: Colors.red[900]),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error Sistem",
        "Terjadi kesalahan yang tidak diketahui: $e",
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }
}
