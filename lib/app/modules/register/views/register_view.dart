import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nusaniaga/app/modules/login/views/login_view.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller (Pastikan ini ada jika tidak menggunakan Binding)
    Get.put(RegisterController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF8FAFF),
        body: Stack(
          children: [
            // Background Elements
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
                            Transform.translate(
                              offset: const Offset(0, -60),
                              child: _buildHeader(),
                            ),
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
                                          "Buat Akun Baru",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1C24),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Lengkapi data diri untuk mendaftar",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 25),

                                        // INPUT NAMA (Perbaikan: controller.nameC)
                                        _buildInput(
                                          label: "Nama Lengkap",
                                          hint: "Masukkan nama Anda",
                                          icon: Icons.person_outline_rounded,
                                          controller: controller.nameC,
                                        ),
                                        const SizedBox(height: 16),

                                        // INPUT NO HP (Perbaikan: controller.phoneC)
                                        _buildInput(
                                          label: "Nomor HP",
                                          hint: "Contoh: 0812xxxx",
                                          icon: Icons.phone_android_rounded,
                                          keyboardType: TextInputType.phone,
                                          controller: controller.phoneC,
                                        ),
                                        const SizedBox(height: 16),

                                        // INPUT EMAIL (Perbaikan: controller.emailC & Hapus "Opsional")
                                        _buildInput(
                                          label: "Email", // Wajib untuk OTP
                                          hint: "email@contoh.com",
                                          icon: Icons.email_outlined,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          controller: controller.emailC,
                                        ),
                                        const SizedBox(height: 16),

                                        // INPUT PASSWORD (Perbaikan: controller.passC)
                                        Obx(
                                          () => _buildInput(
                                            label: "Password",
                                            hint: "Buat password",
                                            icon: Icons.lock_outline_rounded,
                                            controller: controller.passC,
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

                                        // TOMBOL DAFTAR
                                        Obx(
                                          () => _buildSubmitButton(
                                            controller.isLoading.value
                                                ? "LOADING..."
                                                : "DAFTAR SEKARANG",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Footer Login
                            Transform.translate(
                              offset: const Offset(0, -90),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Sudah punya akun? "),
                                  GestureDetector(
                                    // Gunakan Get.off agar tidak menumpuk halaman
                                    onTap: () =>
                                        Get.off(() => const LoginView()),
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
    height: 120, // Sedikit disesuaikan agar proporsional
    width: 120,
    child: Image.asset('assets/logo_app/logo2.png', fit: BoxFit.contain),
  );

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
        onPressed: () => controller.register(),
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
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
