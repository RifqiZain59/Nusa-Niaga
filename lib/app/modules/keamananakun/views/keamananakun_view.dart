import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/keamananakun_controller.dart';

class KeamananakunView extends GetView<KeamananakunController> {
  const KeamananakunView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<KeamananakunController>()) {
      Get.put(KeamananakunController());
    }

    // Warna Tema
    const Color primaryColor = Color(0xFF2563EB);
    const Color backgroundColor = Color(0xFFF9FAFB);
    const Color surfaceColor = Colors.white;

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
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Ionicons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey[200], height: 1),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Ilustrasi / Avatar (Optional)
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFFEFF6FF),
                        child: Icon(
                          Ionicons.person,
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Ionicons.camera,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Form Section
              const Text(
                "Informasi Pribadi",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              _buildModernTextField(
                controller: controller.nameC,
                label: "Nama Lengkap",
                hint: "Masukkan nama lengkap",
                icon: Ionicons.person_outline,
              ),

              const SizedBox(height: 20),

              _buildModernTextField(
                controller: controller.emailC,
                label: "Email Address",
                hint: "contoh@email.com",
                icon: Ionicons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),

              // Info Box Email
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Ionicons.information_circle,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Perubahan email memerlukan verifikasi ulang demi keamanan akun Anda.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Keamanan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              Obx(
                () => _buildModernTextField(
                  controller: controller.passC,
                  label: "Kata Sandi Baru",
                  hint: "Minimal 6 karakter",
                  icon: Ionicons.lock_closed_outline,
                  isObscure: controller.isObscure.value,
                  hasSuffix: true,
                  onSuffixTap: controller.toggleObscure,
                ),
              ),

              const SizedBox(height: 40),

              // Tombol Simpan
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
              suffixIcon: hasSuffix
                  ? IconButton(
                      icon: Icon(
                        isObscure
                            ? Ionicons.eye_off_outline
                            : Ionicons.eye_outline,
                        color: Colors.grey[500],
                      ),
                      onPressed: onSuffixTap,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}
