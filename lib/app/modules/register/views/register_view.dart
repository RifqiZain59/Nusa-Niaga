import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Pastikan import ini sesuai dengan struktur folder Anda
import 'package:nusaniaga/app/modules/login/views/login_view.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // =================================================================
    // SOLUSI ERROR: Inject Controller di sini agar ditemukan oleh GetView
    // =================================================================
    Get.put(RegisterController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset:
            false, // Hindari error pixel overflow saat keyboard muncul
        backgroundColor: const Color(0xFFF8FAFF),
        body: Stack(
          children: [
            // --- Background Decoration ---
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

            // --- Main Content ---
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // Logo Header
                            Transform.translate(
                              offset: const Offset(0, -60),
                              child: _buildHeader(),
                            ),

                            // Form Container
                            Transform.translate(
                              offset: const Offset(0, -90),
                              child: ClipRRect(
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
                                          "Create Account",
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1C24),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Mulai perjalananmu bersama kami",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 25),

                                        // --- INPUT FIELDS ---

                                        // 1. Nama
                                        _buildInput(
                                          label: "Nama Lengkap",
                                          hint: "Masukkan nama lengkap",
                                          icon: Icons.person_outline_rounded,
                                          controller: controller.nameController,
                                        ),
                                        const SizedBox(height: 16),

                                        // 2. Nomor HP (Wajib di API)
                                        _buildInput(
                                          label: "Nomor HP",
                                          hint: "Contoh: 0812xxxx",
                                          icon: Icons.phone_android_rounded,
                                          keyboardType: TextInputType.phone,
                                          controller:
                                              controller.phoneController,
                                        ),
                                        const SizedBox(height: 16),

                                        // 3. Email (Opsional)
                                        _buildInput(
                                          label: "Email (Opsional)",
                                          hint: "example@mail.com",
                                          icon: Icons.mail_outline_rounded,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          controller:
                                              controller.emailController,
                                        ),
                                        const SizedBox(height: 16),

                                        // 4. Password (Reactive Visibility)
                                        Obx(
                                          () => _buildInput(
                                            label: "Password",
                                            hint: "Minimal 8 karakter",
                                            icon: Icons.lock_outline_rounded,
                                            controller:
                                                controller.passwordController,
                                            isPassword: controller
                                                .isPasswordHidden
                                                .value,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                controller
                                                        .isPasswordHidden
                                                        .value
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () => controller
                                                  .isPasswordHidden
                                                  .toggle(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 30),

                                        // --- SUBMIT BUTTON (Reactive Loading) ---
                                        _buildSubmitButton("DAFTAR SEKARANG"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Footer Link to Login
                            Transform.translate(
                              offset: const Offset(0, -90),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Sudah punya akun? "),
                                  GestureDetector(
                                    onTap: () =>
                                        Get.to(() => const LoginView()),
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _buildHeader() => SizedBox(
    height: 220,
    width: 220,
    // Pastikan path asset ini benar sesuai folder Anda
    child: Image.asset('assets/logo_app/logo2.png', fit: BoxFit.contain),
  );

  Widget _buildInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller, // Wajib menerima controller
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
          controller: controller, // Controller dipasang di sini
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
    // Menggunakan Obx untuk memantau status loading
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white.withOpacity(0.5),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

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
          onPressed: () {
            controller.register(); // Panggil fungsi register
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16, // Sedikit diperbesar agar lebih jelas
            ),
          ),
        ),
      );
    });
  }
}
