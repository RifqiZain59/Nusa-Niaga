import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/verifikasi_controller.dart';
// Import halaman LoginView secara langsung
import '../../login/views/login_view.dart';

class VerifikasiView extends GetView<VerifikasiController> {
  const VerifikasiView({super.key});

  @override
  Widget build(BuildContext context) {
    // Safety Check: Inject Controller jika belum ada
    if (!Get.isRegistered<VerifikasiController>()) {
      Get.put(VerifikasiController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Pengaturan Status Bar (Atas)
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.light, // Ikon (baterai, jam) jadi putih
        // --- PERBAIKAN NAVIGATION BAR (BAWAH) ---
        systemNavigationBarColor: Colors.white, // Background nav bar jadi putih
        systemNavigationBarIconBrightness:
            Brightness.dark, // Ikon nav bar jadi gelap agar terlihat
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        // Pastikan Scaffold tidak menggambar di belakang nav bar agar warna putihnya solid
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 1. Background Biru Gradasi
            _buildBlueBackground(),

            // 2. Ikon Transparan sebagai Watermark Background
            _buildTransparentIcon(
              Icons.mark_email_read_outlined,
              top: 100,
              left: -20,
              size: 150,
            ),
            _buildTransparentIcon(
              Icons.security,
              bottom: 50,
              right: -30,
              size: 200,
            ),
            _buildTransparentIcon(
              Icons.mail_lock_outlined,
              top: 250,
              right: 20,
              size: 80,
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      _buildModernGlassCard(),
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
    );
  }

  // Widget Background Biru
  Widget _buildBlueBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
        ),
      ),
    );
  }

  // Widget Ikon Transparan di Background
  Widget _buildTransparentIcon(
    IconData icon, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    double size = 100,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(icon, size: size, color: Colors.white.withOpacity(0.1)),
    );
  }

  // Widget Kartu Glassmorphism Utama
  Widget _buildModernGlassCard() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                _buildAnimatedEmailIcon(),
                const SizedBox(height: 25),
                const Text(
                  "Verifikasi Email",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Color(0xFF1A1C24),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Kami telah mengirimkan link verifikasi ke alamat email Anda:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // --- KOTAK PUTIH EMAIL SOLID ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Obx(
                    () => Text(
                      controller.email.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                _buildPremiumResendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedEmailIcon() {
    return Container(
      height: 90,
      width: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2D62ED),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D62ED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.email_rounded, size: 45, color: Colors.white),
    );
  }

  Widget _buildPremiumResendButton() {
    return Obx(() {
      bool canResend = controller.canResendEmail.value;
      return SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: canResend
              ? () => controller.resendVerificationEmail()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1C24),
            foregroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: Text(
            canResend
                ? "KIRIM ULANG LINK"
                : "Tunggu ${controller.secondsRemaining.value}s",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFooterLink() {
    return InkWell(
      onTap: () {
        // Navigasi langsung ke LoginView dan hapus semua history
        Get.offAll(() => const LoginView());
      },
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: RichText(
          text: const TextSpan(
            text: "Bukan email Anda? ",
            style: TextStyle(color: Colors.white70, fontSize: 14),
            children: [
              TextSpan(
                text: "Ganti Akun",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
