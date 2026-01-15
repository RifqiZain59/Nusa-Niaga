import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Ambil email dari arguments
    if (Get.arguments != null && Get.arguments['email'] != null) {
      email.value = Get.arguments['email'];
    }

    // Mulai cek status verifikasi otomatis tiap 3 detik
    _startEmailVerificationCheck();
    _startResendTimer();
  }

  // --- CEK STATUS OTOMATIS (POLLING) ---
  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      User? user = _auth.currentUser;

      // Sangat Penting: Reload user agar Firebase menarik status terbaru (Verified/Not)
      await user?.reload();

      if (user != null && user.emailVerified) {
        timer.cancel();
        _navigateToHome();
      }
    });
  }

  // --- HITUNG MUNDUR KIRIM ULANG ---
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

  // --- KIRIM ULANG EMAIL ---
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
      Get.snackbar("Error", "Gagal mengirim email. Tunggu sebentar lagi.");
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_login', true);

    Get.offAllNamed('/home');
    Get.snackbar(
      "Sukses",
      "Email berhasil diverifikasi!",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Jika user ingin ganti email/kembali
  void logout() async {
    _timer?.cancel();
    _resendTimer?.cancel();
    await _auth.signOut();
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    super.onClose();
  }
}
