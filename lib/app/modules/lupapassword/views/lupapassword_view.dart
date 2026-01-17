import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/lupapassword_controller.dart';

class LupapasswordView extends GetView<LupapasswordController> {
  const LupapasswordView({super.key});

  // Warna Utama Tema Biru
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF1E40AF); // Ini warna dasar bawah

  @override
  Widget build(BuildContext context) {
    // PENGATURAN STATUS BAR & NAVIGATION BAR MENYESUAIKAN BG
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,

        // MODIFIKASI DISINI:
        systemNavigationBarColor:
            _darkBlue, // Menyesuaikan warna biru gelap di bawah
        systemNavigationBarIconBrightness:
            Brightness.light, // Ikon navigasi jadi PUTIH
      ),
    );

    if (!Get.isRegistered<LupapasswordController>()) {
      Get.put(LupapasswordController());
    }

    return Scaffold(
      // Penting: Cegah resize saat keyboard muncul agar gradient tetap penuh
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // BACKGROUND GRADIENT BIRU
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryBlue, _darkBlue],
              ),
            ),
          ),

          // IKON DEKORASI TRANSPARAN
          Positioned(
            top: -40,
            right: -40,
            child: Icon(
              Ionicons.key_outline,
              size: 250,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Icon(
              Ionicons.shield_checkmark_outline,
              size: 200,
              color: Colors.white.withOpacity(0.05),
            ),
          ),

          // KONTEN UTAMA
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Ionicons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Ionicons.lock_open_outline,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "Lupa Kata Sandi?",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Masukkan email terdaftar Anda untuk menerima tautan reset kata sandi.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Input Field
                        const Text(
                          "Alamat Email",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: controller.emailC,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: "nama@email.com",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                            ),
                            prefixIcon: const Icon(
                              Ionicons.mail_outline,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Tombol
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Obx(() {
                            return ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.sendResetPasswordLink(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _primaryBlue,
                                      ),
                                    )
                                  : const Text(
                                      "Kirim Tautan Reset",
                                      style: TextStyle(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
