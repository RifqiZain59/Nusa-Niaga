import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ionicons/ionicons.dart'; // Pastikan import ini ada
import '../../../data/api_service.dart';
import '../../Profile/controllers/profile_controller.dart';
import '../../login/views/login_view.dart';

class KeamananakunController extends GetxController {
  final ApiService _apiService = ApiService();

  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController phoneC;
  late TextEditingController passC;

  var isLoading = false.obs;
  var isObscure = true.obs;

  File? imageFile;
  var selectedImagePath = ''.obs;
  var currentAvatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    nameC = TextEditingController();
    emailC = TextEditingController();
    phoneC = TextEditingController();
    passC = TextEditingController();
    loadCurrentData();
  }

  void loadCurrentData() async {
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    if (Get.isRegistered<ProfileController>()) {
      final profileC = Get.find<ProfileController>();
      final profile = profileC.userProfile;

      nameC.text = profile['name'] ?? '';
      emailC.text = profile['email'] ?? '';
      phoneC.text = profile['phone'] ?? '';

      if (userId.isNotEmpty) {
        currentAvatarUrl.value = _apiService.getCustomerImageUrl(userId);
      }
    } else {
      nameC.text = prefs.getString('user_name') ?? '';
      emailC.text = prefs.getString('user_email') ?? '';
      phoneC.text = prefs.getString('user_phone') ?? '';

      if (userId.isNotEmpty) {
        currentAvatarUrl.value = _apiService.getCustomerImageUrl(userId);
      }
    }
  }

  void toggleObscure() => isObscure.value = !isObscure.value;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      imageFile = File(image.path);
      selectedImagePath.value = image.path;
    }
  }

  Future<void> updateAccount() async {
    if (nameC.text.trim().isEmpty || emailC.text.trim().isEmpty) {
      _showModernDialog(
        title: "Data Tidak Lengkap",
        message: "Mohon isi Nama dan Email sebelum menyimpan.",
        type: DialogType.warning,
      );
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
        phone: phoneC.text,
        password: passC.text.isNotEmpty ? passC.text : null,
        imageFile: imageFile,
      );

      if (response['status'] == 'success') {
        String newAvatarUrl =
            "${_apiService.getCustomerImageUrl(userId)}?t=${DateTime.now().millisecondsSinceEpoch}";

        await prefs.setString('user_name', nameC.text);
        await prefs.setString('user_email', emailC.text);
        await prefs.setString('user_phone', phoneC.text);
        await prefs.setString('user_avatar', newAvatarUrl);

        if (Get.isRegistered<ProfileController>()) {
          final profileC = Get.find<ProfileController>();
          profileC.userProfile.update(
            'name',
            (_) => nameC.text,
            ifAbsent: () => nameC.text,
          );
          profileC.userProfile.update(
            'email',
            (_) => emailC.text,
            ifAbsent: () => emailC.text,
          );
          profileC.userProfile.update(
            'phone',
            (_) => phoneC.text,
            ifAbsent: () => phoneC.text,
          );
          profileC.userProfile.update(
            'avatar',
            (_) => newAvatarUrl,
            ifAbsent: () => newAvatarUrl,
          );
          profileC.userProfile.refresh();
        }

        Get.back();
        _showModernDialog(
          title: "Berhasil",
          message: "Profil Anda telah berhasil diperbarui.",
          type: DialogType.success,
        );
      } else {
        _showModernDialog(
          title: "Gagal",
          message: response['message'] ?? "Terjadi kesalahan saat menyimpan.",
          type: DialogType.error,
        );
      }
    } catch (e) {
      _showModernDialog(title: "Error", message: "$e", type: DialogType.error);
    } finally {
      isLoading.value = false;
    }
  }

  // --- [UPDATE] POP-UP KONFIRMASI HAPUS AKUN YANG BAGUS ---
  void confirmDeleteAccount() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header Danger
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2), // Merah sangat muda
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Ionicons.trash_bin,
                  color: Color(0xFFEF4444), // Merah
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Hapus Akun Permanen?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              const Text(
                "Tindakan ini tidak dapat dibatalkan. Semua poin, riwayat transaksi, dan data diri Anda akan dihapus selamanya.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _processDeleteAccount();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444), // Merah
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Ya, Hapus",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _processDeleteAccount() async {
    try {
      isLoading.value = true;
      // Tampilkan Loading Dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? '';

      bool success = await _apiService.deleteAccount(userId);
      Get.back(); // Tutup loading

      if (success) {
        await prefs.clear();
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().userProfile.clear();
        }

        Get.offAll(() => const LoginView());

        // Tampilkan snackbar custom di login page
        Get.snackbar(
          "Akun Terhapus",
          "Terima kasih telah menggunakan aplikasi kami.",
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          margin: const EdgeInsets.all(20),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        _showModernDialog(
          title: "Gagal",
          message: "Gagal menghapus akun.",
          type: DialogType.error,
        );
      }
    } catch (e) {
      Get.back(); // Tutup loading jika error
      _showModernDialog(title: "Error", message: "$e", type: DialogType.error);
    } finally {
      isLoading.value = false;
    }
  }

  // --- HELPER UNTUK POP-UP SUPERBAGUS LAINNYA (Success/Error/Warning) ---
  void _showModernDialog({
    required String title,
    required String message,
    required DialogType type,
  }) {
    Color color;
    IconData icon;
    Color bgColor;

    switch (type) {
      case DialogType.success:
        color = const Color(0xFF10B981); // Hijau
        bgColor = const Color(0xFFECFDF5);
        icon = Ionicons.checkmark_circle;
        break;
      case DialogType.error:
        color = const Color(0xFFEF4444); // Merah
        bgColor = const Color(0xFFFEF2F2);
        icon = Ionicons.alert_circle;
        break;
      case DialogType.warning:
        color = const Color(0xFFF59E0B); // Kuning/Orange
        bgColor = const Color(0xFFFFFBEB);
        icon = Ionicons.warning;
        break;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Mengerti",
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
    );
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    passC.dispose();
    super.onClose();
  }
}

// Enum untuk tipe dialog
enum DialogType { success, error, warning }
