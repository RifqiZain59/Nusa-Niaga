import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nusaniaga/app/data/api_service.dart';
import 'package:nusaniaga/app/modules/home/views/home_view.dart';
import 'package:nusaniaga/app/modules/verifikasi/views/verifikasi_view.dart';

class LoginController extends GetxController {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;

  @override
  void onClose() {
    // FIX MEMORY LEAK: Jangan dispose controller di sini saat pakai GetX.
    // Biarkan Flutter/GetX yang mengurusnya secara otomatis.
    super.onClose();
  }

  // Toggle Hidden Password
  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;

  Future<void> login() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      _showCustomDialog(
        title: "Peringatan",
        message: "Email dan Password harus diisi",
        isError: true,
      );
      return;
    }

    isLoading.value = true;

    try {
      // ===================================================================
      // LANGKAH 1: LOGIN KE FIREBASE AUTH
      // (Untuk keamanan password & cek status verifikasi email)
      // ===================================================================
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailC.text, password: passC.text);

      // ===================================================================
      // LANGKAH 2: CEK STATUS VERIFIKASI EMAIL
      // ===================================================================
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        isLoading.value = false;

        // Logout Firebase agar sesi tidak menggantung
        await FirebaseAuth.instance.signOut();

        Get.defaultDialog(
          title: "Belum Verifikasi",
          middleText: "Email Anda belum diverifikasi. Silakan cek email Anda.",
          textConfirm: "Verifikasi Sekarang",
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back(); // Tutup dialog
            Get.to(() => const VerifikasiView(), arguments: emailC.text);
          },
        );
        return;
      }

      // ===================================================================
      // LANGKAH 3: LOGIN KE API SERVICE (BACKEND SENDIRI)
      // (Untuk mengambil data profil lengkap dari database MySQL)
      // ===================================================================
      final response = await ApiService().loginPengguna(
        emailC.text,
        passC.text,
      );

      isLoading.value = false;

      if (response['status'] == 'success') {
        // Login Sukses Sempurna
        Get.offAll(() => const HomeView());
      } else {
        // Firebase Sukses tapi Data di Database Backend Tidak Ditemukan
        await FirebaseAuth.instance.signOut(); // Rollback

        _showCustomDialog(
          title: "Gagal Masuk",
          message:
              response['message'] ?? "Data akun tidak ditemukan di sistem.",
          isError: true,
        );
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String errorMessage = "Gagal Masuk";

      if (e.code == 'user-not-found') {
        errorMessage = "Email tidak terdaftar.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Password salah.";
      } else if (e.code == 'invalid-credential') {
        errorMessage = "Email atau password salah.";
      } else if (e.code == 'too-many-requests') {
        errorMessage =
            "Terlalu banyak percobaan. Silakan tunggu beberapa saat.";
      }

      _showCustomDialog(title: "Gagal", message: errorMessage, isError: true);
    } catch (e) {
      isLoading.value = false;
      _showCustomDialog(
        title: "Error Koneksi",
        message: "Gagal terhubung ke server: $e",
        isError: true,
      );
    }
  }

  void _showCustomDialog({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError ? Icons.cancel_outlined : Icons.check_circle_outline,
                color: isError ? Colors.redAccent : Colors.green,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isError
                        ? Colors.redAccent
                        : Colors.blueAccent,
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
