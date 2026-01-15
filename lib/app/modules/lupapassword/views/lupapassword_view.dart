import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/lupapassword_controller.dart';

class LupapasswordView extends GetView<LupapasswordController> {
  const LupapasswordView({super.key});

  // Warna Utama
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // SOLUSI ERROR: Inject Controller jika belum ada
    // ============================================================
    if (!Get.isRegistered<LupapasswordController>()) {
      Get.put(LupapasswordController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Ionicons.arrow_back, color: _textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 1. HEADER ILUSTRASI
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Ionicons.lock_open_outline,
                    size: 60,
                    color: _primaryBlue,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 2. JUDUL & SUBJUDUL
              const Text(
                "Lupa Kata Sandi?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Jangan khawatir! Masukkan alamat email yang terdaftar pada akun Anda, kami akan mengirimkan link untuk mereset kata sandi.",
                style: TextStyle(
                  fontSize: 16,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // 3. INPUT EMAIL
              const Text(
                "Email",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Masukan email Anda",
                  hintStyle: TextStyle(color: _textSecondary.withOpacity(0.6)),
                  prefixIcon: const Icon(
                    Ionicons.mail_outline,
                    color: _textSecondary,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: _primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 4. TOMBOL KIRIM
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(() {
                  return ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.sendResetPasswordLink(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Kirim Link Reset",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
