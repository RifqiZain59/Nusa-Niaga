import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ionicons/ionicons.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/api_service.dart';
import '../../home/views/home_view.dart';

class LoginController extends GetxController {
  // --- DEPENDENCIES ---
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Client ID dari google-services.json (Sesuai snippet Anda)
  final String _webClientId =
      "130094613281-51akj108ldtaj3s3788gfgg45o9d5714.apps.googleusercontent.com";

  // --- CONTROLLERS ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isLoading = false.obs;
  var isObscure = true.obs;

  void togglePassword() => isObscure.value = !isObscure.value;

  @override
  void onInit() {
    super.onInit();
    // Kita inisialisasi awal di sini untuk memastikan konfigurasi siap
    _initGoogleSignIn();
  }

  void _initGoogleSignIn() {
    try {
      _googleSignIn.initialize(serverClientId: _webClientId);
    } catch (e) {
      print("Google Sign In Init Error: $e");
    }
  }

  // =======================================================================
  // 1. LOGIKA LOGIN GOOGLE (DIPERBARUI)
  // =======================================================================
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // 1. Pastikan inisialisasi (Redundant tapi aman sesuai snippet update)
      //    Beberapa versi plugin butuh re-init jika hot reload
      await _googleSignIn.initialize(serverClientId: _webClientId);

      // 2. Trigger Login Pop-up
      //    Menggunakan authenticate() untuk plugin v7+
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) {
        // User membatalkan login
        isLoading.value = false;
        return;
      }

      // 3. Ambil Authentication Data (ID Token)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 4. Buat Credential Firebase
      //    PENTING: accessToken diset null untuk Google Sign In v7.x ke atas
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      // 5. Sign In ke Firebase Auth
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // 6. Kirim data ke API Server (app.py)
        //    Parameter disesuaikan dengan snippet update: email, name, uid
        final response = await _apiService.loginGoogle(
          email: user.email ?? "",
          name: user.displayName ?? "User Google",
          uid: user.uid,
        );

        if (response != null && response['status'] == 'success') {
          final userData = response['data'];

          // 7. Simpan Session Lokal
          await _saveSession(userData);

          // (Opsional) Catat history login ke Firestore jika diperlukan
          _tryRecordHistory(userData['id'].toString(), userData['name']);

          // 8. Navigasi ke Home
          Get.offAll(() => const HomeView());
        } else {
          _showCenterPopup(
            title: "Gagal Sinkronisasi",
            message: response?['message'] ?? "Gagal menyimpan data ke server.",
            icon: Ionicons.server_outline,
            color: Colors.orange,
          );
          // Jika gagal sync server, logout firebase agar tidak nyangkut
          await _auth.signOut();
        }
      }
    } catch (e) {
      print("Error Login Google: $e");

      String errorMessage = e.toString();
      // Handling error umum agar user friendly
      if (errorMessage.contains("canceled") ||
          errorMessage.contains("cancelled")) {
        // Jangan tampilkan popup jika user cuma cancel
        return;
      }

      _showCenterPopup(
        title: "Gagal Login",
        message: "Terjadi kesalahan saat masuk dengan Google.",
        icon: Ionicons.close_circle,
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =======================================================================
  // 2. LOGIKA LOGIN MANUAL (EMAIL & PASSWORD)
  // =======================================================================
  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showCenterPopup(
        title: "Input Kosong",
        message: "Email dan Password harus diisi",
        icon: Ionicons.alert_circle,
        color: Colors.orange,
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
        await _saveSession(userData);
        _tryRecordHistory(userData['id'].toString(), userData['name']);
        _showSuccessPopup("Selamat Datang kembali!");
      } else {
        _showCenterPopup(
          title: "Gagal Login",
          message: response?['message'] ?? "Email atau Password salah.",
          icon: Ionicons.close_circle,
          color: Colors.red,
        );
      }
    } catch (e) {
      _showCenterPopup(
        title: "Error Sistem",
        message: "Gagal menghubungi server: $e",
        icon: Ionicons.warning,
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =======================================================================
  // HELPER FUNCTIONS
  // =======================================================================

  Future<void> _saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userData['id'].toString());
    await prefs.setString('user_name', userData['name'] ?? 'User');
    await prefs.setString('user_email', userData['email'] ?? '');
    await prefs.setString('user_phone', userData['phone'] ?? '');
    await prefs.setString('user_role', userData['role'] ?? 'Member');
    await prefs.setBool('is_login', true);
  }

  Future<void> _tryRecordHistory(String userId, String userName) async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceName = 'Unknown Device';
      String platform = 'Unknown OS';

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = "${androidInfo.brand} ${androidInfo.model}";
        platform = 'Android ${androidInfo.version.release}';
      }

      await _firestore.collection('login_history').add({
        'customer_id': userId,
        'customer_name': userName,
        'device_name': deviceName,
        'platform': platform,
        'login_time': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Gagal mencatat riwayat login: $e");
    }
  }

  void _showSuccessPopup(String message) async {
    _showCenterPopup(
      title: "Berhasil",
      message: message,
      icon: Ionicons.checkmark_circle,
      color: Colors.green,
    );
    await Future.delayed(const Duration(milliseconds: 1200));
    Get.offAll(() => const HomeView());
  }

  void _showCenterPopup({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    if (Get.isDialogOpen == true) Get.back();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Get.isDialogOpen == true) Get.back();
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
