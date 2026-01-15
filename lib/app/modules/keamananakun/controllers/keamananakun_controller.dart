// lib/app/modules/keamananakun/controllers/keamananakun_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api_service.dart';
import '../../Profile/controllers/profile_controller.dart';

class KeamananakunController extends GetxController {
  final ApiService _apiService = ApiService();

  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController passC;

  var isLoading = false.obs;
  var isObscure = true.obs;

  File? imageFile;
  var selectedImagePath = ''.obs;

  // TAMBAHAN: Untuk menyimpan URL gambar saat ini dari server
  var currentImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    nameC = TextEditingController();
    emailC = TextEditingController();
    passC = TextEditingController();
    loadCurrentData();
  }

  void loadCurrentData() async {
    final prefs = await SharedPreferences.getInstance();
    nameC.text = prefs.getString('user_name') ?? '';
    emailC.text = prefs.getString('user_email') ?? '';

    String userId = prefs.getString('user_id') ?? '';
    if (userId.isNotEmpty) {
      // Set URL gambar dari server. Tambahkan timestamp agar tidak cache.
      currentImageUrl.value =
          '${ApiService.baseUrl}/customer_image/$userId?v=${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  void toggleObscure() {
    isObscure.value = !isObscure.value;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      imageFile = File(image.path);
      selectedImagePath.value = image.path;
    }
  }

  Future<void> updateAccount() async {
    if (nameC.text.isEmpty || emailC.text.isEmpty) {
      Get.snackbar("Error", "Nama dan Email tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? '';

      final response = await _apiService.updateProfile(
        userId: userId,
        name: nameC.text,
        email: emailC.text,
        password: passC.text.isNotEmpty ? passC.text : null,
        imageFile: imageFile,
      );

      if (response['status'] == 'success') {
        await prefs.setString('user_name', nameC.text);
        await prefs.setString('user_email', emailC.text);

        // Refresh halaman Profile jika controller-nya ada
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().loadProfile();
        }

        Get.snackbar("Sukses", "Profil berhasil diperbarui");

        // KEMBALI KE HALAMAN SEBELUMNYA (PROFILE)
        Get.back();
      } else {
        Get.snackbar("Gagal", response['message'] ?? "Terjadi kesalahan");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal update: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }
}
