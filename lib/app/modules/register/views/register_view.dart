import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Import Controller
import '../controllers/register_controller.dart';

// Import View Login
import '../../login/views/login_view.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  // --- PALETTE WARNA BIRU PREMIUM ---
  static const Color primaryBlue = Color(0xFF2962FF); // Biru Utama
  static const Color lightBlue = Color(0xFF448AFF); // Biru Terang
  static const Color darkBlue = Color(0xFF0D47A1); // Biru Gelap
  static const Color bgBlue = Color(0xFFF0F4FD); // Background Very Light Blue
  static const Color textDark = Color(0xFF1E293B); // Text Hitam/Abu Tua

  @override
  Widget build(BuildContext context) {
    // Safety Check: Inject Controller jika belum ada
    if (!Get.isRegistered<RegisterController>()) {
      Get.put(RegisterController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: bgBlue,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // Perbaikan UX: Set true agar form naik saat keyboard muncul
        resizeToAvoidBottomInset: true,
        backgroundColor: bgBlue,
        body: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              // --- BACKGROUND DECORATION ---
              // Bola Gradasi Atas Kanan
              Positioned(
                top: -80,
                right: -60,
                child: _buildGradientCircle(
                  size: 300,
                  colors: [
                    primaryBlue.withOpacity(0.4),
                    Colors.lightBlueAccent.withOpacity(0.1),
                  ],
                ),
              ),
              // Bola Gradasi Bawah Kiri
              Positioned(
                bottom: -100,
                left: -60,
                child: _buildGradientCircle(
                  size: 350,
                  colors: [
                    darkBlue.withOpacity(0.3),
                    Colors.blue.withOpacity(0.05),
                  ],
                ),
              ),
              // Bola Kecil Tengah
              Positioned(
                top: Get.height * 0.2,
                left: 20,
                child: _buildCircle(60, Colors.blue.withOpacity(0.08)),
              ),

              // --- MAIN CONTENT ---
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    // Bouncing scroll effect untuk kesan iOS/Premium
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LOGO
                        _buildHeader(),

                        const SizedBox(height: 30),

                        // --- GLASS CARD FORM ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  0.7,
                                ), // Lebih solid sedikit agar mudah dibaca
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.8),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.1),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Judul Form
                                  const Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: textDark,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Bergabunglah bersama kami sekarang",
                                    style: TextStyle(
                                      color: textDark.withOpacity(0.6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // 1. INPUT NAMA
                                  _buildInput(
                                    label: "Nama Lengkap",
                                    hint: "Nama Anda",
                                    icon: Icons.person_rounded,
                                    controller: controller.nameController,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 18),

                                  // 2. INPUT EMAIL
                                  _buildInput(
                                    label: "Alamat Email",
                                    hint: "contoh@email.com",
                                    icon: Icons.alternate_email_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    controller: controller.emailController,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 18),

                                  // 3. INPUT NO HP
                                  _buildInput(
                                    label: "Nomor Telepon",
                                    hint: "0812...",
                                    icon: Icons.phone_iphone_rounded,
                                    keyboardType: TextInputType.phone,
                                    controller: controller.phoneController,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 18),

                                  // 4. INPUT PASSWORD
                                  Obx(
                                    () => _buildInput(
                                      label: "Kata Sandi",
                                      hint: "Minimal 6 karakter",
                                      icon: Icons.lock_rounded,
                                      controller: controller.passwordController,
                                      isPassword: controller.isObscure.value,
                                      textInputAction: TextInputAction.done,
                                      suffixIcon: IconButton(
                                        onPressed: () =>
                                            controller.togglePassword(),
                                        icon: Icon(
                                          controller.isObscure.value
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: Colors.grey.shade500,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // TOMBOL REGISTER
                                  Obx(
                                    () => _buildSubmitButton(
                                      controller.isLoading.value
                                          ? "Memproses..."
                                          : "Daftar Sekarang",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // NAVIGASI LOGIN
                        _buildLoginLink(),

                        const SizedBox(
                          height: 20,
                        ), // Spacer bawah agar tidak mepet
                      ],
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

  // ==========================================================
  // WIDGET HELPERS (REFINED)
  // ==========================================================

  Widget _buildInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569), // Blue Grey
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(
                icon,
                color: primaryBlue.withOpacity(0.8),
                size: 22,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: primaryBlue, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String label) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [primaryBlue, lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () => controller.register(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah punya akun?",
          style: TextStyle(
            color: textDark.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () => Get.off(() => const LoginView()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: const Text(
              " Masuk Disini",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryBlue,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox(
            height: 70,
            width: 70,
            child: Image.asset(
              'assets/logo_app/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, stack) => const Icon(
                Icons.app_registration_rounded,
                size: 40,
                color: primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper untuk lingkaran biasa
  Widget _buildCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  // Helper untuk lingkaran gradient (Efek lebih premium)
  Widget _buildGradientCircle({
    required double size,
    required List<Color> colors,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
