import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nusaniaga/app/modules/login/views/login_view.dart';
import '../controllers/verifikasi_controller.dart';

class VerifikasiView extends GetView<VerifikasiController> {
  const VerifikasiView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<VerifikasiController>()) {
      Get.put(VerifikasiController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: Stack(
          children: [
            _buildCircle(
              300,
              Colors.blue.withOpacity(0.2),
              top: -50,
              right: -50,
            ),
            _buildCircle(
              250,
              Colors.lightBlue.withOpacity(0.15),
              bottom: -100,
              left: -50,
            ),
            _buildCircle(
              100,
              Colors.cyan.withOpacity(0.1),
              top: 200,
              left: -30,
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 20),
                      _buildGlassCard(),
                      const SizedBox(height: 20),
                      _buildFooterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
            children: [
              _buildEmailIcon(),
              const SizedBox(height: 20),
              const Text(
                "Cek Email Anda",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C24),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Kami telah mengirimkan link verifikasi ke:",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 5),
              Obx(
                () => Text(
                  controller.email.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Silakan buka email Anda dan klik tautan yang kami kirimkan untuk mengaktifkan akun.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              _buildResendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: controller.canResendEmail.value
              ? () => controller.resendVerificationEmail()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            disabledBackgroundColor: Colors.grey[400],
          ),
          child: Text(
            controller.canResendEmail.value
                ? "KIRIM ULANG LINK"
                : "KIRIM ULANG (${controller.secondsRemaining.value}s)",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailIcon() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.blueAccent.withOpacity(0.1),
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.mark_email_unread_outlined,
      size: 50,
      color: Colors.blueAccent,
    ),
  );

  Widget _buildLogo() => Image.asset(
    'assets/logo_app/logo2.png',
    height: 100,
    width: 100,
    errorBuilder: (c, e, s) => const Icon(
      Icons.mark_email_read_rounded,
      size: 80,
      color: Colors.blueAccent,
    ),
  );

  Widget _buildFooterLink() => GestureDetector(
    onTap: () => controller.logout(),
    child: RichText(
      text: TextSpan(
        text: "Salah email? ",
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
        children: const [
          TextSpan(
            text: "Kembali Daftar/Login",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCircle(
    double size,
    Color color, {
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) => Positioned(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    ),
  );
}
