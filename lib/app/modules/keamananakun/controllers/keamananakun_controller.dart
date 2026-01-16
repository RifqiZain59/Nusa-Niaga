import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api_service.dart';
// Pastikan import profile controller benar
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
  var currentAvatarUrl = ''.obs; // Menampung URL avatar saat ini

  @override
  void onInit() {
    super.onInit();
    nameC = TextEditingController();
    emailC = TextEditingController();
    passC = TextEditingController();
    loadCurrentData();
  }

  void loadCurrentData() async {
    // Cara 1: Ambil dari ProfileController (Lebih cepat/konsisten)
    if (Get.isRegistered<ProfileController>()) {
      final profile = Get.find<ProfileController>().userProfile;
      nameC.text = profile['name'] ?? '';
      emailC.text = profile['email'] ?? '';
      currentAvatarUrl.value = profile['avatar'] ?? '';
    }
    // Cara 2: Fallback ke SharedPreferences jika ProfileController mati
    else {
      final prefs = await SharedPreferences.getInstance();
      nameC.text = prefs.getString('user_name') ?? '';
      emailC.text = prefs.getString('user_email') ?? '';
      currentAvatarUrl.value = prefs.getString('user_avatar') ?? '';
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
      selectedImagePath.value = image.path; // Update UI preview lokal
    }
  }

  Future<void> updateAccount() async {
    if (nameC.text.trim().isEmpty || emailC.text.trim().isEmpty) {
      Get.snackbar("Error", "Nama dan Email tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? '';

      // 1. KIRIM DATA KE SERVER
      final response = await _apiService.updateProfile(
        userId: userId,
        name: nameC.text,
        email: emailC.text,
        password: passC.text.isNotEmpty ? passC.text : null,
        imageFile: imageFile,
      );

      // 2. CEK RESPON
      if (response['status'] == 'success') {
        var newData = response['data'];

        // Ambil URL gambar baru dari respon server
        // Sesuaikan key dengan backend ('photo_url', 'image_url', atau 'avatar')
        String newAvatarUrl =
            newData['photo_url'] ?? newData['image_url'] ?? '';

        // 3. PENTING: SIMPAN KE PROFILE CONTROLLER AGAR PERMANEN
        if (Get.isRegistered<ProfileController>()) {
          final profileC = Get.find<ProfileController>();

          await profileC.saveUserData(
            id: userId,
            name: newData['name'], // Nama dari server
            email: newData['email'], // Email dari server
            avatarUrl: newAvatarUrl.isNotEmpty ? newAvatarUrl : null,
          );
        } else {
          // Fallback manual jika ProfileController belum di-put
          await prefs.setString('user_name', newData['name']);
          await prefs.setString('user_email', newData['email']);
          if (newAvatarUrl.isNotEmpty) {
            await prefs.setString('user_avatar', newAvatarUrl);
          }
        }

        Get.back(); // Kembali ke halaman Profile
        Get.snackbar("Sukses", "Profil berhasil diperbarui!");
      } else {
        Get.snackbar("Gagal", response['message'] ?? "Terjadi kesalahan");
      }
    } catch (e) {
      print("Error update: $e");
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
