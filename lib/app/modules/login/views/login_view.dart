import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nusaniaga/app/modules/lupapassword/views/lupapassword_view.dart';
import '../controllers/login_controller.dart';
import '../../register/views/register_view.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  static const Color primaryBlue = Color(0xFF2962FF);
  static const Color lightBlue = Color(0xFF448AFF);
  static const Color textDark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LoginController>()) {
      Get.put(LoginController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: primaryBlue,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              // --- 1. BACKGROUND BIRU SOLID ---
              Positioned.fill(child: Container(color: primaryBlue)),

              // --- 2. ICON TRANSPARAN (WATERMARK) ---
              Positioned(
                top: -30,
                right: -40,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.store_mall_directory_rounded,
                    size: 280,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -30,
                child: Opacity(
                  opacity: 0.07,
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 220,
                    color: Colors.white,
                  ),
                ),
              ),

              // --- 3. MAIN CONTENT ---
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
                        _buildHeader(), // Logo App
                        const SizedBox(height: 30),

                        // --- GLASS CARD FORM ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.8),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Welcome Back!",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: textDark,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Silakan masuk untuk melanjutkan",
                                    style: TextStyle(
                                      color: textDark.withOpacity(0.6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  _buildInput(
                                    label: "Email",
                                    hint: "email@anda.com",
                                    icon: Icons.alternate_email_rounded,
                                    controller: controller.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),

                                  const SizedBox(height: 18),

                                  Obx(
                                    () => _buildInput(
                                      label: "Password",
                                      hint: "Masukkan kata sandi",
                                      icon: Icons.lock_outline_rounded,
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

                                  const SizedBox(height: 12),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () => Get.to(
                                        () => const LupapasswordView(),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Text(
                                          "Lupa Password?",
                                          style: TextStyle(
                                            color: primaryBlue,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Tombol Masuk Biasa
                                  Obx(
                                    () => _buildSubmitButton(
                                      controller.isLoading.value
                                          ? "MEMPROSES..."
                                          : "MASUK",
                                    ),
                                  ),

                                  // --- GOOGLE SIGN IN SECTION ---
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          "ATAU",
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
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
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          controller.loginWithGoogle(),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      // Menggunakan icon Google dari URL Wikimedia
                                      icon: Image.network(
                                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                                        height: 24,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.g_mobiledata,
                                                  color: Colors.red,
                                                  size: 30,
                                                ),
                                      ),
                                      label: const Text(
                                        "Masuk dengan Google",
                                        style: TextStyle(
                                          color: textDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // ----------------------------------------
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildFooterLink(),
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

  // --- HELPER WIDGETS ---

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
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          // [PERBAIKAN] Tidak menggunakan height fixed agar fleksibel
          constraints: const BoxConstraints(minHeight: 55),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: textDark,
                fontSize: 15, // Ukuran font sedikit diperbesar
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: Icon(
                  icon,
                  color: primaryBlue.withOpacity(0.8),
                  size: 22,
                ),
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                isDense: true, // Membuat layout lebih compact
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18, // Padding vertikal yang cukup
                ),
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
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [primaryBlue, lightBlue]),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : () => controller.login(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: SizedBox(
        height: 80,
        width: 80,
        child: Image.asset(
          'assets/logo_app/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.store, size: 50, color: primaryBlue),
        ),
      ),
    );
  }

  Widget _buildFooterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Belum punya akun? ",
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
        ),
        GestureDetector(
          onTap: () => Get.off(() => const RegisterView()),
          child: const Text(
            "Daftar Sekarang",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
