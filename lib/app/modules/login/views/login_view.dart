import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nusaniaga/app/modules/lupapassword/views/lupapassword_view.dart';
import '../controllers/login_controller.dart';
import '../../register/views/register_view.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  // --- PALETTE WARNA ---
  static const Color primaryBlue = Color(0xFF2962FF);
  static const Color lightBlue = Color(0xFF448AFF);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color bgBlue = Color(0xFFF0F4FD);
  static const Color textDark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LoginController>()) {
      Get.put(LoginController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: bgBlue,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: bgBlue,
        body: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              // --- BACKGROUND DECORATION ---
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                color: Colors.white.withOpacity(0.7),
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

                                  // 1. INPUT EMAIL
                                  _buildInput(
                                    label: "Email",
                                    hint: "email@anda.com",
                                    icon: Icons.alternate_email_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    controller: controller.emailController,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 18),

                                  // 2. INPUT PASSWORD
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

                                  // 3. LUPA PASSWORD (NAVIGASI KE FORGOT PASSWORD)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () {
                                        // Pindah ke halaman Forgot Password
                                        Get.to(() => const LupapasswordView());
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 4,
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

                                  // 4. TOMBOL LOGIN
                                  Obx(
                                    () => _buildSubmitButton(
                                      controller.isLoading.value
                                          ? "MEMPROSES..."
                                          : "MASUK",
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // DIVIDER
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          "atau masuk dengan",
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
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

                                  // 5. TOMBOL GOOGLE
                                  _buildGoogleButton(),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // FOOTER KE REGISTER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Belum punya akun? ",
                              style: TextStyle(
                                color: textDark.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.off(() => const RegisterView()),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                child: const Text(
                                  "Daftar Sekarang",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                    fontSize: 15,
                                  ),
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
      height: 55,
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
                height: 24,
                width: 24,
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
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: () => Get.snackbar("Info", "Login Google Clicked"),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
              height: 24,
              errorBuilder: (ctx, err, stack) =>
                  const Icon(Icons.public, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            const Text(
              "Google",
              style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
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
          BoxShadow(
            color: primaryBlue.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SizedBox(
        height: 80,
        width: 80,
        child: Image.asset(
          'assets/logo_app/logo2.png',
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) => const Icon(
            Icons.store_mall_directory_rounded,
            size: 50,
            color: primaryBlue,
          ),
        ),
      ),
    );
  }

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
