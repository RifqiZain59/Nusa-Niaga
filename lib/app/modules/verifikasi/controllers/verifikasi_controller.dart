import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class VerifikasiController extends GetxController {
  // Status loading
  final RxBool isLoading = false.obs;

  // Variabel email (untuk tampilan UI saja)
  late String email;

  @override
  void onInit() {
    super.onInit();

    // Ambil user saat ini dari Firebase
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Jika ada user login, gunakan emailnya. Jika tidak, ambil dari arguments
    email = currentUser?.email ?? Get.arguments ?? "email@tidakdiketahui.com";
  }

  // ==========================================================
  // FUNGSI KIRIM VERIFIKASI VIA FIREBASE
  // ==========================================================
  Future<void> resendVerificationLink() async {
    isLoading.value = true;

    // Tampilkan Loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        // 1. Kirim Link Verifikasi bawaan Firebase
        await user.sendEmailVerification();

        Get.back(); // Tutup Loading
        isLoading.value = false;

        Get.snackbar(
          "Berhasil",
          "Link verifikasi telah dikirim ke ${user.email}. Cek inbox atau spam.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (user != null && user.emailVerified) {
        Get.back(); // Tutup Loading
        isLoading.value = false;

        Get.snackbar(
          "Info",
          "Email ini sudah terverifikasi.",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // User bernilai null (Session habis / belum login)
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'Tidak ada pengguna yang login.',
        );
      }
    } on FirebaseAuthException catch (e) {
      Get.back(); // Tutup Loading
      isLoading.value = false;

      String message = "Gagal mengirim link.";

      // Handle error spesifik Firebase
      if (e.code == 'too-many-requests') {
        message = "Terlalu banyak permintaan. Silakan tunggu beberapa saat.";
      } else {
        message = e.message ?? message;
      }

      Get.snackbar(
        "Gagal",
        message,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.back(); // Tutup Loading
      isLoading.value = false;

      Get.snackbar(
        "Error",
        "Terjadi kesalahan: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
