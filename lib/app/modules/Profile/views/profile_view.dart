import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

// Import Controller & ApiService
import '../controllers/profile_controller.dart';
import '../../../data/api_service.dart';

// IMPORT HALAMAN KEAMANAN AKUN (EDIT PROFIL)
import '../../keamananakun/views/keamananakun_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  // --- PALET WARNA ---
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF1E40AF);
  static const Color _backgroundColor = Color(0xFFF8F9FD);
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);

  static final RxBool _isPhoneVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: RefreshIndicator(
          onRefresh: controller.refreshProfile,
          color: _primaryBlue,
          child: SingleChildScrollView(
            // Menggunakan BouncingScrollPhysics agar scroll terasa lebih halus dan elastis
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              children: [
                // Jarak aman dari Status Bar
                SizedBox(height: MediaQuery.of(context).padding.top + 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // 1. KARTU IDENTITAS BIRU (DENGAN ICON)
                      _buildBlueIdentityCard(),

                      const SizedBox(height: 30),

                      // MENU 1: PENGATURAN AKUN
                      _buildSectionTitle('Pengaturan Akun'),
                      _buildMenuContainer(
                        children: [
                          _buildMenuItem(
                            icon: Ionicons.person_outline,
                            title: 'Edit Profil',
                            subtitle: 'Ubah nama & data diri',
                            onTap: () {
                              Get.to(
                                () => const KeamananakunView(),
                              )?.then((_) => controller.loadProfile());
                            },
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Ionicons.time_outline,
                            title: 'History Login',
                            subtitle: 'Riwayat aktivitas masuk akun',
                            onTap: () {
                              Get.snackbar(
                                "Info",
                                "Fitur History Login segera hadir",
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // MENU 2: AKTIVITAS BELANJA
                      _buildSectionTitle('Aktivitas Belanja'),
                      _buildMenuContainer(
                        children: [
                          _buildMenuItem(
                            icon: Ionicons.bag_check_outline,
                            title: 'Pesanan Saya',
                            onTap: () => Get.toNamed('/pesanansaya'),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Ionicons.heart_outline,
                            title: 'Wishlist',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Ionicons.headset_outline,
                            title: 'Pusat Bantuan',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // 2. TOMBOL KELUAR
                      _buildLogoutButton(),

                      const SizedBox(height: 30),

                      // INFO VERSI
                      const Text(
                        "Versi Aplikasi 1.0.0",
                        style: TextStyle(color: _textSecondary, fontSize: 12),
                      ),

                      // --- PERBAIKAN SCROLL ---
                      // Memberikan ruang kosong di bawah agar konten terakhir bisa di-scroll ke atas nav bar
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET KARTU IDENTITAS BIRU ---
  Widget _buildBlueIdentityCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryBlue, _darkBlue],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Dekorasi Icon Transparan di pojok kanan bawah kartu
          Positioned(
            bottom: -30,
            right: -20,
            child: Icon(
              Ionicons.person_circle,
              size: 180,
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Obx(() {
              final user = controller.userProfile;
              final String userId = user['id'] ?? '';
              final String name = user['name'] ?? 'Pengguna Baru';
              final String email = user['email'] ?? 'Belum ada email';
              final String phone = user['phone'] ?? '-';
              final String imageUrl =
                  '${ApiService.baseUrl}/customer_image/$userId?v=${controller.imageSignature}';

              return Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white24,
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.white,
                          backgroundImage: userId.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: userId.isEmpty
                              ? const Icon(
                                  Ionicons.person,
                                  color: _primaryBlue,
                                  size: 30,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Teks Identitas
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.85),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  // Kotak Nomor HP (Transparan di dalam kartu biru)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Ionicons.call,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() {
                            bool visible = _isPhoneVisible.value;
                            String displayPhone = phone;
                            if (!visible && phone.length > 4) {
                              displayPhone =
                                  "${phone.substring(0, 4)} **** ****";
                            }
                            return Text(
                              displayPhone,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            );
                          }),
                        ),
                        GestureDetector(
                          onTap: () => _isPhoneVisible.toggle(),
                          child: Obx(
                            () => Icon(
                              _isPhoneVisible.value
                                  ? Ionicons.eye_off
                                  : Ionicons.eye,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primaryBlue, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: _textSecondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Ionicons.chevron_forward,
                size: 18,
                color: Color(0xFFD1D5DB),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 78,
      endIndent: 20,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red.shade600,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.shade100, width: 1),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.log_out_outline),
            SizedBox(width: 10),
            Text(
              "Keluar Aplikasi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "Konfirmasi",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "Apakah Anda yakin ingin keluar?",
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      radius: 16,
      onConfirm: () {
        Get.back();
        controller.logout();
      },
    );
  }
}
