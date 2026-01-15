import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/keamananakun_controller.dart';

class KeamananakunView extends GetView<KeamananakunController> {
  const KeamananakunView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller secara lazy jika belum ada
    if (!Get.isRegistered<KeamananakunController>()) {
      Get.put(KeamananakunController());
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFF,
      ), // Background sedikit abu/biru muda
      appBar: AppBar(
        title: const Text(
          'Keamanan Akun',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Perbarui Profil",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Perbarui informasi akun Anda di sini.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 25),

            // === INPUT NAMA ===
            _buildLabel("Nama Lengkap"),
            _buildTextField(
              controller: controller.nameC,
              hint: "Nama Lengkap Anda",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            // === INPUT EMAIL ===
            _buildLabel("Email Address"),
            _buildTextField(
              controller: controller.emailC,
              hint: "Email Anda",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            // Info box kecil untuk email
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Jika email diubah, kami akan mengirimkan link verifikasi ulang.",
                      style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // === INPUT PASSWORD BARU ===
            _buildLabel("Password Baru (Opsional)"),
            Obx(
              () => _buildTextField(
                controller: controller.passC,
                hint: "Kosongkan jika tidak ingin ubah",
                icon: Icons.lock_outline,
                isObscure: controller.isObscure.value,
                hasSuffix: true,
                onSuffixTap: controller.toggleObscure,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "* Minimal 6 karakter",
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 40),

            // === TOMBOL SIMPAN ===
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null // Disable tombol saat loading
                      : () => controller.updateAccount(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "SIMPAN PERUBAHAN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Label Text
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
          fontSize: 14,
        ),
      ),
    );
  }

  // Helper Widget untuk TextField Kustom
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    bool hasSuffix = false,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          suffixIcon: hasSuffix
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onSuffixTap,
                )
              : null,
        ),
      ),
    );
  }
}
