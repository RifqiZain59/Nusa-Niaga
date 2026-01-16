import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. IMPORT LoginView Anda di sini
// Pastikan path ini sesuai dengan struktur folder project Anda
import '../../login/views/login_view.dart';

class VerifikasiController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State
  var email = "".obs;
  var isLoading = false.obs;
  var canResendEmail = false.obs;
  var secondsRemaining = 60.obs;

  Timer? _timer;
  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments['email'] != null) {
      email.value = Get.arguments['email'];
    }

    _startEmailVerificationCheck();
    _startResendTimer();
  }

  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      User? user = _auth.currentUser;
      await user?.reload();

      if (user != null && user.emailVerified) {
        timer.cancel();
        // 2. Diarahkan ke proses penyelesaian verifikasi
        _handleVerificationSuccess();
      }
    });
  }

  void _startResendTimer() {
    canResendEmail.value = false;
    secondsRemaining.value = 60;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        canResendEmail.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> resendVerificationEmail() async {
    try {
      isLoading.value = true;
      User? user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        _startResendTimer();
        Get.snackbar("Berhasil", "Link baru telah dikirim.");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengirim email.");
    } finally {
      isLoading.value = false;
    }
  }

  // Perubahan: Navigasi ke Login setelah sukses verifikasi
  void _handleVerificationSuccess() async {
    // Tetap simpan status login jika diperlukan,
    // atau biarkan user login ulang melalui LoginView
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_login', true);

    Get.snackbar(
      "Sukses",
      "Email berhasil diverifikasi! Silakan masuk kembali.",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    // Navigasi langsung menggunakan kelas LoginView
    Get.offAll(() => const LoginView());
  }

  // Jika user klik "Ganti Akun"
  void logout() async {
    _timer?.cancel();
    _resendTimer?.cancel();
    await _auth.signOut();

    // Navigasi langsung menggunakan kelas LoginView
    Get.offAll(() => const LoginView());
  }

  @override
  void onClose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    super.onClose();
  }
}
