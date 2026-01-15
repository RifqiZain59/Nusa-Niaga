import 'dart:convert'; // Untuk jsonEncode
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // Import HTTP

class KeamananakunController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // URL API FLASK ANDA
  // Ganti dengan IP Address laptop jika pakai Emulator (misal: 192.168.1.x:5000)
  final String baseUrl = "http://10.0.2.2:5000";

  // Controller Text
  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController passC;

  // State Loading
  var isLoading = false.obs;
  var isObscure = true.obs;

  @override
  void onInit() {
    super.onInit();
    User? user = _auth.currentUser;
    nameC = TextEditingController(text: user?.displayName ?? "");
    emailC = TextEditingController(text: user?.email ?? "");
    passC = TextEditingController();
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }

  void toggleObscure() => isObscure.value = !isObscure.value;

  // =======================================================================
  // FUNGSI UPDATE DATA (FIREBASE + API)
  // =======================================================================
  Future<void> updateAccount() async {
    isLoading.value = true;
    User? user = _auth.currentUser;

    if (user == null) {
      isLoading.value = false;
      Get.snackbar("Error", "Sesi habis, silakan login ulang.");
      return;
    }

    try {
      // -----------------------------------------------------------------
      // 1. UPDATE KE FIREBASE (PRIORITAS UTAMA)
      // -----------------------------------------------------------------

      // A. Update Nama di Firebase
      if (nameC.text.isNotEmpty && nameC.text != user.displayName) {
        await user.updateDisplayName(nameC.text);
      }

      // B. Update Email di Firebase (Perlu verifikasi ulang biasanya)
      if (emailC.text.isNotEmpty && emailC.text != user.email) {
        // Uncomment baris bawah jika ingin mengaktifkan ganti email
        // await user.verifyBeforeUpdateEmail(emailC.text);
      }

      // C. Update Password di Firebase
      if (passC.text.isNotEmpty) {
        if (passC.text.length < 6) {
          throw FirebaseAuthException(
            code: 'weak-password',
            message: 'Password minimal 6 karakter',
          );
        }
        await user.updatePassword(passC.text);
      }

      // Reload user agar data di object 'user' terupdate
      await user.reload();

      // -----------------------------------------------------------------
      // 2. SINKRONISASI KE API BACKEND (MYSQL via FLASK)
      // -----------------------------------------------------------------
      // Kita panggil fungsi khusus untuk nembak API
      await _syncToBackend(
        uid: user.uid,
        name: nameC.text,
        email: emailC.text, // Email dikirim untuk update/validasi
        password: passC.text.isNotEmpty
            ? passC.text
            : null, // Kirim null jika password tidak diganti
      );

      // -----------------------------------------------------------------
      // 3. SUKSES
      // -----------------------------------------------------------------
      Get.snackbar(
        "Sukses",
        "Data akun berhasil diperbarui di Aplikasi & Server!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Bersihkan field password setelah sukses
      passC.clear();
    } on FirebaseAuthException catch (e) {
      // ERROR DARI FIREBASE
      _handleFirebaseError(e);
    } catch (e) {
      // ERROR UMUM / API ERROR
      print("Error General: $e");
      Get.snackbar(
        "Peringatan",
        "Data update di Firebase, tapi gagal sinkron ke Server Backend. ($e)",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =======================================================================
  // FUNGSI KHUSUS API REQUEST
  // =======================================================================
  Future<void> _syncToBackend({
    required String uid,
    required String name,
    required String email,
    String? password,
  }) async {
    // URL Endpoint Update Profile di Flask Anda
    final Uri url = Uri.parse("$baseUrl/update-profile");

    // Body Data
    Map<String, dynamic> data = {
      'uid': uid, // Penting: Identifikasi user berdasarkan UID Firebase
      'name': name,
      'email': email,
    };

    // Hanya kirim password jika user mengisinya
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          // "Authorization": "Bearer $token" // Jika pakai token
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("API Sync Success: ${response.body}");
      } else {
        // Jika server menolak (misal error 400/500)
        throw Exception("Gagal update server: ${response.statusCode}");
      }
    } catch (e) {
      // Lempar error agar ditangkap di catch utama
      throw Exception("Koneksi API Gagal: $e");
    }
  }

  // Helper Handle Error Firebase
  void _handleFirebaseError(FirebaseAuthException e) {
    String message = "Gagal update profil.";
    if (e.code == 'requires-recent-login') {
      message =
          "Sesi habis. Silakan Logout dan Login kembali untuk mengganti password.";
    } else if (e.code == 'weak-password') {
      message = "Password terlalu lemah (min. 6 karakter).";
    } else if (e.code == 'email-already-in-use') {
      message = "Email sudah digunakan akun lain.";
    }

    Get.snackbar(
      "Gagal",
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}
