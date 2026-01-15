import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan ini jika ingin cek manual

// Ganti path ini sesuai lokasi file controller dan view kamu
import 'package:nusaniaga/app/modules/login/views/login_view.dart';
import '../controllers/verifikasi_controller.dart';

class VerifikasiView extends GetView<VerifikasiController> {
  const VerifikasiView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller secara lazy jika belum ada
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
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF8FAFF),
        body: Stack(
          children: [
            // ===========================================
            // BACKGROUND DECORATION (Bubbles)
            // ===========================================
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

            // ===========================================
            // MAIN CONTENT
            // ===========================================
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo App
                      _buildLogo(),

                      const SizedBox(height: 20),

                      // Card Glassmorphism
                      _buildGlassCard(),

                      const SizedBox(height: 20),

                      // Tombol Salah Email / Kembali
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

  // Widget Logo
  Widget _buildLogo() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: SizedBox(
        height: 100,
        width: 100,
        child: Image.asset(
          'assets/logo_app/logo2.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.mark_email_read_rounded, // Icon fallback jika logo tidak ada
            size: 80,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  // Widget Kartu Utama (Glassmorphism)
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
              // Icon Email Bulat
              Container(
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
              ),
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

              // Menampilkan Email
              Text(
                controller.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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

              // Tombol Kirim Ulang Link (Dengan Obx untuk Loading State)
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null // Disable tombol saat loading
                        : () => controller.resendVerificationLink(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Colors.blueAccent.withOpacity(0.3),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.send_rounded, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                "KIRIM ULANG LINK",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Tombol Sudah Verifikasi
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () async {
                    // Cek status manual sebelum ke Login (Fitur Tambahan)
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await user.reload(); // Refresh data user dari server
                      if (user.emailVerified) {
                        Get.snackbar(
                          "Sukses",
                          "Akun berhasil diverifikasi!",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        // Arahkan ke Dashboard/Home jika sudah verified
                        // Get.offAll(() => const HomeView());
                      }
                    }
                    // Default: Kembali ke Login
                    Get.offAll(() => const LoginView());
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "SAYA SUDAH VERIFIKASI",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  // Link Bagian Bawah
  Widget _buildFooterLink() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: RichText(
        text: TextSpan(
          text: "Salah email? ",
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
          children: const [
            TextSpan(
              text: "Kembali Daftar",
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
  }

  // Helper Background Circle
  Widget _buildCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
