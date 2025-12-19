import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class RegisterController extends GetxController {
  // Instance ApiService
  final ApiService _apiService = ApiService();

  // Observables
  var isPasswordHidden = true.obs;
  var isLoading = false.obs; // Untuk menangani loading indicator

  // Text Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController(); // Wajib untuk API
  final passwordController = TextEditingController(); // Wajib untuk API
  final emailController = TextEditingController(); // Opsional

  // Fungsi Register
  void register() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String email = emailController.text.trim();

    // 1. Validasi Input Dasar
    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Nama, Nomor HP, dan Password wajib diisi!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true; // Mulai loading

      // 2. Panggil API registerPengguna
      // Perhatikan: email bersifat opsional (named parameter) di api_service.dart
      final response = await _apiService.registerPengguna(
        name,
        phone,
        password,
        email: email.isNotEmpty ? email : null,
      );

      isLoading.value = false; // Selesai loading

      // 3. Cek Respon
      if (response['status'] == 'success') {
        Get.snackbar(
          "Berhasil",
          "Registrasi berhasil! Silakan login.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigasi: Kembali ke halaman login atau tutup halaman register
        // Contoh: Get.offNamed('/login'); atau
        Get.back();
      } else {
        // Jika status error dari backend (misal: No HP sudah terdaftar)
        Get.snackbar(
          "Gagal",
          response['message'] ?? "Registrasi gagal",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Terjadi kesalahan sistem: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    // Bersihkan controller saat halaman ditutup
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
