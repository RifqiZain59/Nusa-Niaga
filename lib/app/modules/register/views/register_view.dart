import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import '../../login/views/login_view.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  static const Color primaryBlue = Color(0xFF2962FF);
  static const Color textDark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RegisterController>()) {
      Get.put(RegisterController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: primaryBlue,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              // --- BACKGROUND BIRU SOLID ---
              Positioned.fill(child: Container(color: primaryBlue)),

              // --- ICON TRANSPARAN (WATERMARK) ---
              Positioned(
                top: 20,
                left: -30,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 220,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: -40,
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(
                    Icons.assignment_ind_rounded,
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),

              // --- MAIN CONTENT ---
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Bergabunglah bersama kami sekarang",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _buildInput(
                                    label: "Nama Lengkap",
                                    hint: "Nama Anda",
                                    icon: Icons.person_rounded,
                                    controller: controller.nameController,
                                  ),
                                  const SizedBox(height: 18),
                                  _buildInput(
                                    label: "Alamat Email",
                                    hint: "contoh@email.com",
                                    icon: Icons.alternate_email_rounded,
                                    controller: controller.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 18),
                                  _buildInput(
                                    label: "Nomor Telepon",
                                    hint: "0812...",
                                    icon: Icons.phone_iphone_rounded,
                                    controller: controller.phoneController,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 18),
                                  Obx(
                                    () => _buildInput(
                                      label: "Kata Sandi",
                                      hint: "Minimal 6 karakter",
                                      icon: Icons.lock_rounded,
                                      controller: controller.passwordController,
                                      isPassword: controller.isObscure.value,
                                      suffixIcon: IconButton(
                                        onPressed: () =>
                                            controller.togglePassword(),
                                        icon: Icon(
                                          controller.isObscure.value
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
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
                        _buildLoginLink(),
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

  // --- WIDGET HELPERS ---
  Widget _buildInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
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
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: primaryBlue),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () => controller.register(),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Sudah punya akun?",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () => Get.off(() => const LoginView()),
          child: const Text(
            " Masuk Disini",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Image.asset(
        'assets/logo_app/logo.png',
        height: 70,
        width: 70,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.app_registration_rounded,
          size: 40,
          color: primaryBlue,
        ),
      ),
    );
  }
}
