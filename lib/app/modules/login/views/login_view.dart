import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Import Controller
import '../controllers/login_controller.dart';

// Import View Lain
import '../../register/views/register_view.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller jika belum ada
    if (!Get.isRegistered<LoginController>()) {
      Get.put(LoginController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // FIX ERROR GEOMETRY: Tambahkan ini
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF8FAFF),
        body: Stack(
          children: [
            // Background Bubbles (Desain Asli Anda)
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
                              offset: const Offset(0, -40),
                              child: _buildHeader(),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -20),
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
                                          "Welcome Back",
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1C24),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Silahkan masuk ke akun Anda",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 25),

                                        // INPUT EMAIL
                                        _buildInput(
                                          label: "Email",
                                          hint: "example@mail.com",
                                          icon: Icons.mail_outline_rounded,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          controller: controller
                                              .emailController, // Fix nama variable
                                        ),
                                        const SizedBox(height: 16),

                                        // INPUT PASSWORD
                                        Obx(
                                          () => _buildInput(
                                            label: "Password",
                                            hint: "Masukkan password",
                                            icon: Icons.lock_outline_rounded,
                                            controller: controller
                                                .passwordController, // Fix nama variable
                                            isPassword: controller
                                                .isObscure
                                                .value, // Fix nama variable
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

                                        // TOMBOL LUPA PASSWORD
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              Get.snackbar(
                                                "Info",
                                                "Fitur Lupa Password",
                                              );
                                            },
                                            child: const Text(
                                              "Lupa Password?",
                                              style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),

                                        // TOMBOL LOGIN
                                        Obx(
                                          () => _buildSubmitButton(
                                            controller.isLoading.value
                                                ? "LOADING..."
                                                : "MASUK SEKARANG",
                                          ),
                                        ),

                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Divider(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              child: Text(
                                                "atau",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),

                                        // TOMBOL GOOGLE
                                        _buildGoogleButton(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // TEXT DAFTAR
                            Transform.translate(
                              offset: const Offset(0, -10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Belum punya akun? "),
                                  GestureDetector(
                                    onTap: () =>
                                        Get.to(() => const RegisterView()),
                                    child: const Text(
                                      "Daftar",
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

  // --- WIDGET BUILDER HELPERS (Sesuai kode asli Anda) ---

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
        onPressed: controller.isLoading.value ? null : () => controller.login(),
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
                ),
              ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Image.network(
          'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
          height: 24,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.public),
        ),
        label: const Text(
          "Masuk dengan Google",
          style: TextStyle(
            color: Color(0xFF1A1C24),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white.withOpacity(0.5),
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
    height: 200,
    width: 200,
    child: Image.asset(
      'assets/logo_app/logo2.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.store, size: 100, color: Colors.blue),
    ),
  );
}
