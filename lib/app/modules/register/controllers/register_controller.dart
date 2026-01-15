import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Firebase
import 'package:nusaniaga/app/data/api_service.dart'; // 2. ApiService Sendiri
import 'package:nusaniaga/app/modules/verifikasi/views/verifikasi_view.dart';

class RegisterController extends GetxController {
  // Instance ApiService
  final ApiService _apiService = ApiService();

  // Instance FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController nameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    passC.dispose();
    super.onClose();
  }

  Future<void> register() async {
    // 1. Validasi Input
    if (nameC.text.isEmpty ||
        emailC.text.isEmpty ||
        phoneC.text.isEmpty ||
        passC.text.isEmpty) {
      _showCustomDialog(
        title: "Peringatan",
        message: "Semua kolom wajib diisi",
        isError: true,
      );
      return;
    }

    isLoading.value = true;

    try {
      // ============================================================
      // LANGKAH 1: DAFTAR KE FIREBASE (Untuk Auth & Verifikasi)
      // ============================================================
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailC.text,
            password: passC.text,
          );

      // Update Display Name di Firebase (Opsional, biar rapi)
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(nameC.text);
      }

      // ============================================================
      // LANGKAH 2: SIMPAN DATA LENGKAP KE API BACKEND SENDIRI
      // ============================================================
      try {
        final response = await _apiService.registerPengguna(
          nameC.text,
          phoneC.text,
          passC
              .text, // Password juga dikirim ke backend jika backend butuh login manual juga
          emailC.text,
        );

        // Cek Respon dari Backend kamu
        if (response['status'] == 'success') {
          // ============================================================
          // LANGKAH 3: KIRIM EMAIL VERIFIKASI (Fitur Firebase)
          // ============================================================
          await userCredential.user!.sendEmailVerification();

          isLoading.value = false;

          // Navigasi ke View Verifikasi
          Get.off(() => const VerifikasiView(), arguments: emailC.text);
        } else {
          // JIKA BACKEND GAGAL (Misal: DB Error / No HP duplikat di DB sendiri)
          // Kita harus MENGHAPUS user di Firebase agar tidak jadi akun "sampah"
          // yang ada di Firebase tapi tidak ada di database kita.
          await userCredential.user!.delete();

          throw Exception(
            response['message'] ?? "Gagal menyimpan data ke server.",
          );
        }
      } catch (eBackend) {
        // Tangkap error spesifik saat request ke Backend
        // Hapus user firebase jika backend error (Rollback mechanism)
        if (_auth.currentUser != null) {
          await _auth.currentUser!.delete();
        }
        throw Exception("Backend Error: $eBackend");
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String errorMessage = "Gagal registrasi.";

      // Handle Error Firebase
      if (e.code == 'weak-password') {
        errorMessage = "Password terlalu lemah (min 6 karakter).";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Email sudah terdaftar di sistem.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Format email tidak valid.";
      }

      _showCustomDialog(
        title: "Firebase Auth Error",
        message: errorMessage,
        isError: true,
      );
    } catch (e) {
      isLoading.value = false;
      // Menangani error umum lainnya
      _showCustomDialog(
        title: "Gagal",
        message: e.toString().replaceAll(
          "Exception:",
          "",
        ), // Bersihkan tulisan Exception
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
        child: Container(
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
