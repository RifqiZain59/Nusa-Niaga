import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/keamananakun_controller.dart';

class KeamananakunView extends GetView<KeamananakunController> {
  const KeamananakunView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    Get.lazyPut(() => KeamananakunController());

    // --- WARNA TEMA ---
    const Color primaryColor = Color(0xFF2563EB); // Biru Utama
    const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
    const Color textDark = Color(0xFF1E293B); // Slate 800
    const Color textLight = Color(0xFF64748B); // Slate 500
    const Color inputFill = Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Edit Profil',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.only(left: 10),
            child: IconButton(
              icon: const Icon(Ionicons.arrow_back, color: textDark),
              onPressed: () => Get.back(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey[200], height: 1),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. FOTO PROFIL ---
              Center(
                child: GestureDetector(
                  onTap: () => controller.pickImage(),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Obx(() {
                          if (controller.selectedImagePath.value.isNotEmpty) {
                            return CircleAvatar(
                              radius: 60,
                              backgroundImage: FileImage(
                                File(controller.selectedImagePath.value),
                              ),
                            );
                          } else if (controller
                              .currentAvatarUrl
                              .value
                              .isNotEmpty) {
                            return CircleAvatar(
                              radius: 60,
                              backgroundColor: const Color(0xFFEFF6FF),
                              backgroundImage: NetworkImage(
                                controller.currentAvatarUrl.value,
                              ),
                            );
                          } else {
                            return CircleAvatar(
                              radius: 60,
                              backgroundColor: const Color(0xFFEFF6FF),
                              child: const Icon(
                                Ionicons.person,
                                size: 60,
                                color: primaryColor,
                              ),
                            );
                          }
                        }),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 6, right: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Ionicons.camera,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- 2. FORM INPUT ---
              _buildSectionTitle("Informasi Pribadi", textDark),
              const SizedBox(height: 16),

              _buildModernTextField(
                controller: controller.nameC,
                label: "Nama Lengkap",
                hint: "Masukkan nama Anda",
                icon: Ionicons.person_outline,
                primaryColor: primaryColor,
                fillColor: inputFill,
                textLight: textLight,
              ),
              const SizedBox(height: 20),

              _buildModernTextField(
                controller: controller.emailC,
                label: "Alamat Email",
                hint: "contoh@email.com",
                icon: Ionicons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                primaryColor: primaryColor,
                fillColor: inputFill,
                textLight: textLight,
              ),
              const SizedBox(height: 20),

              _buildModernTextField(
                controller: controller.phoneC,
                label: "Nomor Telepon",
                hint: "08xxxxxxxxxx",
                icon: Ionicons.call_outline,
                keyboardType: TextInputType.phone,
                primaryColor: primaryColor,
                fillColor: inputFill,
                textLight: textLight,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle("Keamanan", textDark),
              const SizedBox(height: 16),

              Obx(
                () => _buildModernTextField(
                  controller: controller.passC,
                  label: "Kata Sandi Baru",
                  hint: "Biarkan kosong jika tidak diubah",
                  icon: Ionicons.lock_closed_outline,
                  isObscure: controller.isObscure.value,
                  hasSuffix: true,
                  onSuffixTap: controller.toggleObscure,
                  primaryColor: primaryColor,
                  fillColor: inputFill,
                  textLight: textLight,
                ),
              ),

              const SizedBox(height: 40),

              // --- 3. TOMBOL SIMPAN ---
              Obx(
                () => Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.updateAccount(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                        : const Text(
                            "Simpan Perubahan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- 4. KOTAK PERINGATAN HAPUS AKUN (SUPERBAGUS) ---
              _buildDeleteAccountBox(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET ZONA BAHAYA ---
  Widget _buildDeleteAccountBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Merah Sangat Muda (Background)
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFECACA), // Merah Muda (Border)
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Ionicons.warning_outline,
                  color: Color(0xFFDC2626), // Merah Tua
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Zona Berbahaya",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF991B1B), // Merah Gelap
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Menghapus akun Anda bersifat permanen. Semua data riwayat transaksi, poin, dan informasi profil akan hilang dan tidak dapat dikembalikan.",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7F1D1D),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => controller.confirmDeleteAccount(),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFEF4444), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFFDC2626),
              ),
              child: const Text(
                "Hapus Akun Saya",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    required Color fillColor,
    required Color textLight,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    bool hasSuffix = false,
    VoidCallback? onSuffixTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscure,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
              suffixIcon: hasSuffix
                  ? IconButton(
                      icon: Icon(
                        isObscure
                            ? Ionicons.eye_off_outline
                            : Ionicons.eye_outline,
                        color: Colors.grey[400],
                        size: 22,
                      ),
                      onPressed: onSuffixTap,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
              filled: true,
              fillColor: fillColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
