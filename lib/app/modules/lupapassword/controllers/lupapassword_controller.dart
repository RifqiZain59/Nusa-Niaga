import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LupapasswordController extends GetxController {
  // 1. Text Controller untuk mengambil input user
  late TextEditingController emailC;

  // 2. Variable untuk loading state (agar tombol bisa muter saat proses)
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
    emailC.dispose(); // Wajib dispose agar memori tidak bocor
    super.onClose();
  }

  // 3. FUNGSI UTAMA: Kirim Reset Password
  Future<void> sendResetPasswordLink() async {
    String email = emailC.text.trim();

    // Validasi Input Kosong
    if (email.isEmpty) {
      Get.snackbar(
        "Error",
        "Email tidak boleh kosong",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi Format Email
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Error",
        "Format email tidak valid",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true; // Mulai Loading

      // --- CORE LOGIC FIREBASE ---
      await _auth.sendPasswordResetEmail(email: email);
      // ---------------------------

      isLoading.value = false; // Stop Loading

      // Tampilkan Pesan Sukses
      Get.snackbar(
        "Berhasil",
        "Link reset password telah dikirim ke $email. Silakan cek Inbox atau folder Spam email Anda.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // Opsional: Kosongkan field setelah kirim
      emailC.clear();
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      // Handle Error Spesifik dari Firebase
      String errorMessage = "Terjadi kesalahan.";

      if (e.code == 'user-not-found') {
        errorMessage = "Email ini belum terdaftar di aplikasi.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Format email yang dimasukkan salah.";
      } else {
        errorMessage = e.message ?? "Gagal mengirim email reset.";
      }

      Get.snackbar(
        "Gagal",
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Terjadi kesalahan sistem.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
