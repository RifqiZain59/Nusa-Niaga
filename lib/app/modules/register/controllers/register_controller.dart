import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_service.dart';

// --- IMPORT LANGSUNG DISINI ---
import '../../verifikasi/views/verifikasi_view.dart';

class RegisterController extends GetxController {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isLoading = false.obs;
  var isObscure = true.obs;

  void togglePassword() => isObscure.value = !isObscure.value;

  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Semua kolom wajib diisi",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 1. Buat User di Firebase
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        // 2. Kirim Email Verifikasi
        await userCredential.user!.sendEmailVerification();

        // 3. Simpan data ke Database Flask Anda
        // PERBAIKAN: Gunakan 'registerPengguna' dan sesuaikan urutan parameternya
        // Urutan di ApiService: (name, phone, password, email)
        await _apiService.registerPengguna(
          nameController.text.trim(), // name
          phoneController.text.trim(), // phone
          passwordController.text.trim(), // password
          emailController.text.trim(), // email
        );

        // 4. PINDAH HALAMAN
        Get.offAll(
          () => const VerifikasiView(),
          arguments: {'email': emailController.text.trim()},
        );

        Get.snackbar(
          "Berhasil Daftar",
          "Link verifikasi telah dikirim ke email Anda.",
          backgroundColor: Colors.blueAccent,
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan";
      if (e.code == 'email-already-in-use') {
        message = "Email sudah terdaftar. Silakan login.";
      } else if (e.code == 'weak-password') {
        message = "Password terlalu lemah.";
      }
      Get.snackbar("Gagal", message, backgroundColor: Colors.orange);
    } catch (e) {
      Get.snackbar("Error", "Gagal terhubung: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
