import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Import Controller
import '../controllers/register_controller.dart';

// Import View Login (Untuk navigasi "Sudah punya akun?")
import '../../login/views/login_view.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller jika belum ada (Safety Check)
    if (!Get.isRegistered<RegisterController>()) {
      Get.put(RegisterController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // Mencegah error geometry saat keyboard muncul
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF8FAFF),
        body: Stack(
          children: [
            // --- BACKGROUND BUBBLES (Sama seperti Login) ---
            Positioned(
              top: -50,
              right: -50,
              child: _buildCircle(300, Colors.blue.withOpacity(0.2)),
            ),
            Positioned(
              bottom: -100,
              left: -50,
              child: _buildCircle(250, Colors.lightBlue.withOpacity(0.15)),
            ),
            Positioned(
              top: 200,
              left: -30,
              child: _buildCircle(100, Colors.cyan.withOpacity(0.1)),
            ),

            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // HEADER LOGO
                            Transform.translate(
                              offset: const Offset(0, -20),
                              child: _buildHeader(),
                            ),

                            // --- FORM REGISTRASI ---
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 15,
                                  sigmaY: 15,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Buat Akun Baru",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1C24),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Lengkapi data diri Anda",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 25),

                                      // 1. NAMA LENGKAP
                                      _buildInput(
                                        label: "Nama Lengkap",
                                        hint: "Contoh: Budi Santoso",
                                        icon: Icons.person_outline_rounded,
                                        controller: controller.nameController,
                                      ),
                                      const SizedBox(height: 16),

                                      // 2. EMAIL
                                      _buildInput(
                                        label: "Email",
                                        hint: "example@mail.com",
                                        icon: Icons.mail_outline_rounded,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: controller.emailController,
                                      ),
                                      const SizedBox(height: 16),

                                      // 3. NO HP
                                      _buildInput(
                                        label: "No. Telepon",
                                        hint: "0812xxxx",
                                        icon: Icons.phone_android_rounded,
                                        keyboardType: TextInputType.phone,
                                        controller: controller.phoneController,
                                      ),
                                      const SizedBox(height: 16),

                                      // 4. PASSWORD
                                      Obx(
                                        () => _buildInput(
                                          label: "Password",
                                          hint: "Buat password aman",
                                          icon: Icons.lock_outline_rounded,
                                          controller:
                                              controller.passwordController,
                                          isPassword:
                                              controller.isObscure.value,
                                          suffixIcon: IconButton(
                                            onPressed: () =>
                                                controller.togglePassword(),
                                            icon: Icon(
                                              controller.isObscure.value
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 30),

                                      // TOMBOL DAFTAR
                                      Obx(
                                        () => _buildSubmitButton(
                                          controller.isLoading.value
                                              ? "MEMPROSES..."
                                              : "DAFTAR SEKARANG",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // NAVIGASI KE LOGIN
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Sudah punya akun? "),
                                GestureDetector(
                                  onTap: () => Get.off(() => const LoginView()),
                                  child: const Text(
                                    "Masuk",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // WIDGET HELPER (Agar kodingan rapi)
  // ==========================================================

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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C24),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: Colors.blueAccent.withOpacity(0.7),
              size: 22,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Colors.blueAccent,
                width: 1.5,
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
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.blue],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _buildHeader() => SizedBox(
    height: 150,
    width: 150,
    child: Image.asset(
      'assets/logo_app/logo2.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.person_add, size: 80, color: Colors.blue),
    ),
  );
}
