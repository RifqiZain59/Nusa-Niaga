import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api_service.dart';
import '../../home/views/home_view.dart';

class LoginController extends GetxController {
  final ApiService _apiService = ApiService();

  // --- INPUT CONTROLLER ---
  // Nama variable disesuaikan dengan View Anda
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // --- STATE ---
  var isLoading = false.obs;
  var isObscure = true.obs; // Default: Password tertutup

  void togglePassword() {
    isObscure.value = !isObscure.value;
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Email dan Password harus diisi",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await _apiService.loginPengguna(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (response != null && response['status'] == 'success') {
        final userData = response['data'];

        // Simpan Data Sesi
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userData['id'].toString());
        await prefs.setString('user_name', userData['name'] ?? 'User');
        await prefs.setString('user_email', userData['email'] ?? '');
        await prefs.setString('user_phone', userData['phone'] ?? '');
        await prefs.setString('user_role', userData['role'] ?? 'Member');
        await prefs.setBool('is_login', true);

        Get.offAll(() => const HomeView());
        Get.snackbar("Sukses", "Selamat Datang kembali!");
      } else {
        Get.snackbar("Gagal", response?['message'] ?? "Login Gagal");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan sistem");
    } finally {
      isLoading.value = false;
    }
  }
}
