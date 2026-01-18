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

  // Client ID dari google-services.json
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
  // 1. LOGIKA LOGIN GOOGLE (SUDAH BENAR)
  // =======================================================================
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      await _googleSignIn.initialize(serverClientId: _webClientId);

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // Sync ke backend via UID
        final response = await _apiService.loginGoogle(
          email: user.email ?? "",
          name: user.displayName ?? "User Google",
          uid: user.uid,
        );

        if (response['status'] == 'success') {
          _handleSuccessLogin(response['data']);
        } else {
          _handleBackendError(response);
        }
      }
    } catch (e) {
      _handleGeneralError("Login Google Gagal", e);
    } finally {
      isLoading.value = false;
    }
  }

  // =======================================================================
  // 2. LOGIKA LOGIN MANUAL (DIPERBAIKI: Firebase Auth First)
  // =======================================================================
  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
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

      // [LANGKAH KUNCI]: Login ke Firebase Auth DULU
      // Ini memastikan password terbaru (hasil reset email) terbaca.
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Jika password di Firebase benar, ambil data profil dari Backend pakai UID
        // Kita TIDAK LAGI kirim password ke backend.
        final response = await _apiService.loginViaUid(user.uid);

        if (response['status'] == 'success') {
          _handleSuccessLogin(response['data']);
        } else {
          // Kasus aneh: Login Firebase sukses, tapi data di backend server hilang/rusak
          await _auth.signOut();
          _showCenterPopup(
            title: "Data Tidak Ditemukan",
            message:
                "Akun valid, tapi profil pengguna tidak ditemukan di server.",
            icon: Ionicons.server_outline,
            color: Colors.orange,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle Error Spesifik Firebase (Password Salah, User Ga Ada, dll)
      String title = "Gagal Login";
      String msg = "Terjadi kesalahan.";

      if (e.code == 'user-not-found') {
        msg = "Email tidak terdaftar.";
      } else if (e.code == 'wrong-password') {
        msg = "Password salah.";
      } else if (e.code == 'invalid-email') {
        msg = "Format email salah.";
      } else if (e.code == 'user-disabled') {
        msg = "Akun ini telah dinonaktifkan.";
      } else if (e.code == 'too-many-requests') {
        msg = "Terlalu banyak percobaan. Silakan coba lagi nanti.";
      } else {
        msg = e.message ?? "Gagal autentikasi.";
      }

      _showCenterPopup(
        title: title,
        message: msg,
        icon: Ionicons.close_circle,
        color: Colors.red,
      );
    } catch (e) {
      _handleGeneralError("Error Sistem", e);
    } finally {
      isLoading.value = false;
    }
  }

  // =======================================================================
  // HELPER FUNCTIONS
  // =======================================================================

  Future<void> _handleSuccessLogin(Map<String, dynamic> userData) async {
    await _saveSession(userData);
    _tryRecordHistory(userData['id'].toString(), userData['name']);
    _showSuccessPopup("Selamat Datang, ${userData['name']}!");
  }

  void _handleBackendError(Map<String, dynamic> response) async {
    await _auth.signOut();
    _showCenterPopup(
      title: "Gagal Sinkronisasi",
      message: response['message'] ?? "Gagal terhubung ke server database.",
      icon: Ionicons.server_outline,
      color: Colors.orange,
    );
  }

  void _handleGeneralError(String title, dynamic e) {
    // Filter error user cancel agar tidak mengganggu
    if (e.toString().contains("canceled")) return;

    print("Login Error: $e");
    _showCenterPopup(
      title: title,
      message: "Terjadi kesalahan: $e",
      icon: Ionicons.warning,
      color: Colors.red,
    );
  }

  Future<void> _saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userData['id'].toString());
    await prefs.setString('user_name', userData['name'] ?? 'User');
    await prefs.setString('user_email', userData['email'] ?? '');
    await prefs.setString('user_phone', userData['phone'] ?? '');
    await prefs.setString('user_role', userData['role'] ?? 'Member');
    // Simpan avatar jika ada
    if (userData['photo_url'] != null || userData['image_url'] != null) {
      await prefs.setString(
        'user_avatar',
        userData['photo_url'] ?? userData['image_url'],
      );
    }
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
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name ?? 'iPhone';
        platform = 'iOS ${iosInfo.systemVersion}';
      }

      await _firestore.collection('login_history').add({
        'customer_id': userId,
        'customer_name': userName,
        'device_name': deviceName,
        'platform': platform,
        'login_time': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
