import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_service.dart';
import '../../verifikasi/views/verifikasi_view.dart';

class RegisterController extends GetxController {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers untuk input field
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isLoading = false.obs;
  var isObscure = true.obs;

  void togglePassword() => isObscure.value = !isObscure.value;

  @override
  void onClose() {
    // Membersihkan controller saat halaman ditutup untuk mencegah memory leak
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    // Validasi Input
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showSnackbar("Error", "Semua kolom wajib diisi", Colors.redAccent);
      return;
    }

    try {
      isLoading.value = true;

      // 1. Simpan ke Database Flask DULU (Best Practice)
      // Ini mencegah user terdaftar di Firebase tapi gagal masuk database lokal
      final response = await _apiService.registrasiPengguna(
        nameController.text.trim(),
        emailController.text.trim(),
        phoneController.text.trim(),
        passwordController.text.trim(),
      );

      // Anggap saja jika sukses, API mengembalikan status sukses atau tidak error
      // Jika _apiService.registrasiPengguna melempar error, proses akan langsung ke 'catch'

      // 2. Buat User di Firebase
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        // 3. Kirim Email Verifikasi
        await userCredential.user!.sendEmailVerification();

        // 4. Pindah ke Halaman Verifikasi
        Get.offAll(
          () => const VerifikasiView(),
          arguments: {'email': emailController.text.trim()},
        );

        _showSnackbar(
          "Berhasil Daftar",
          "Silakan cek email Anda untuk verifikasi.",
          Colors.green,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Error spesifik Firebase (misal: email sudah digunakan)
      String message = "Terjadi kesalahan";
      if (e.code == 'email-already-in-use') {
        message = "Email sudah terdaftar.";
      } else if (e.code == 'weak-password') {
        message = "Password terlalu lemah.";
      }
      _showSnackbar("Gagal", message, Colors.redAccent);
    } catch (e) {
      // Error lainnya (Server Flask mati, dsb)
      _showSnackbar("Error", "Gagal terhubung ke server: $e", Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper function untuk snackbar agar kode lebih bersih
  void _showSnackbar(String title, String message, Color bgColor) {
    Get.snackbar(
      title,
      message,
      backgroundColor: bgColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
    );
  }
}
