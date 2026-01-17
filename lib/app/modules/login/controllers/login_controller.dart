import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ionicons/ionicons.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/api_service.dart';
import '../../home/views/home_view.dart';

class LoginController extends GetxController {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isLoading = false.obs;
  var isObscure = true.obs;

  void togglePassword() => isObscure.value = !isObscure.value;

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
        String userId = userData['id'].toString();
        String userName = userData['name'] ?? 'User';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
        await prefs.setString('user_name', userName);
        await prefs.setString('user_email', userData['email'] ?? '');
        await prefs.setString('user_phone', userData['phone'] ?? '');
        await prefs.setString('user_role', userData['role'] ?? 'Member');
        await prefs.setBool('is_login', true);

        // --- COBA REKAM KE DATABASE ---
        try {
          await _recordLoginToDatabase(userId, userName);
        } catch (dbError) {
          // Jika gagal rekam database, kita print errornya tapi JANGAN stop login
          print("Database Error: $dbError");
          // Opsional: Tampilkan popup jika ingin debug
          // Get.snackbar("Info", "Gagal rekam history: $dbError");
        }

        _showCenterPopup(
          title: "Berhasil",
          message: "Selamat Datang kembali!",
          icon: Ionicons.checkmark_circle,
          color: Colors.green,
        );

        await Future.delayed(const Duration(milliseconds: 1200));
        Get.offAll(() => const HomeView());
      } else {
        String message = response?['message'] ?? "Login Gagal";
        _showCenterPopup(
          title: "Gagal Login",
          message: message,
          icon: Ionicons.close_circle,
          color: Colors.red,
        );
      }
    } catch (e) {
      print("System Error: $e");
      _showCenterPopup(
        title: "Error Sistem",
        message: "Terjadi kesalahan: $e",
        icon: Ionicons.warning,
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI REKAM DATABASE (DENGAN DEBUG) ---
  Future<void> _recordLoginToDatabase(String userId, String userName) async {
    // 1. Cek Koneksi Device Info
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

    print("Mencoba kirim ke Firestore: login_history...");

    // 2. Tulis ke Firestore
    // Gunakan .set() dengan merge agar tidak duplikat atau .add() untuk log baru terus
    await _firestore
        .collection('login_history')
        .add({
          'customer_id': userId,
          'customer_name': userName,
          'device_name': deviceName,
          'platform': platform,
          'login_time': FieldValue.serverTimestamp(),
          'created_at_local': DateTime.now().toString(),
        })
        .then((value) {
          print("SUKSES! Data tersimpan di ID: ${value.id}");
        })
        .catchError((error) {
          // INI AKAN MUNCUL DI CONSOLE JIKA GAGAL
          print("GAGAL MENYIMPAN KE FIRESTORE: $error");
          throw error; // Lempar error agar ditangkap di catch atas
        });
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 50, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
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
