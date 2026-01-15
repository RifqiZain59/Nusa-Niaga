import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Penting untuk Status Bar
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

// Import Controller
import '../controllers/profile_controller.dart';
import '../../keamananakun/views/keamananakun_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  // Warna
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF1E40AF);
  static const Color _backgroundColor = Color(0xFFF8F9FD);
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    // Mengatur Status Bar menjadi Icon Putih & Transparan backgroundnya
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent, // Agar warna biru header tembus ke atas
        statusBarIconBrightness: Brightness.light, // Icon status bar jadi PUTIH
        statusBarBrightness: Brightness.dark, // Untuk iOS
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(), // Efek scroll lebih padat
            child: Column(
              children: [
                // 1. HEADER KOTAK (Tanpa Lengkung)
                _buildSquareHeader(context),

                // 2. BAGIAN STATS (Overlap sedikit ke biru)
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildStatsCard(),

                        const SizedBox(height: 20),

                        // MENU SECTIONS
                        _buildSectionTitle('Pengaturan Akun'),
                        _buildMenuCard(
                          children: [
                            _buildMenuItem(
                              icon: Ionicons.lock_closed_outline,
                              title: 'Keamanan Akun',
                              subtitle: 'Password & Verifikasi',
                              onTap: () =>
                                  Get.to(() => const KeamananakunView()),
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Ionicons.location_outline,
                              title: 'Alamat Pengiriman',
                              subtitle: 'Atur alamat rumah & kantor',
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _buildSectionTitle('Aktivitas Belanja'),
                        _buildMenuCard(
                          children: [
                            _buildMenuItem(
                              icon: Ionicons.bag_check_outline,
                              title: 'Pesanan Saya',
                              badgeCount: 2,
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Ionicons.heart_outline,
                              title: 'Wishlist',
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Ionicons.chatbox_ellipses_outline,
                              title: 'Ulasan',
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

                        // LOGOUT BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: TextButton(
                            onPressed: controller.logout,
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFEF2F2),
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // Radius tombol
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Ionicons.log_out_outline),
                                SizedBox(width: 8),
                                Text(
                                  "Keluar Aplikasi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                        const Text(
                          "Versi Aplikasi 1.0.0",
                          style: TextStyle(color: _textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET BUILDER
  // ============================================================

  Widget _buildSquareHeader(BuildContext context) {
    // Mengambil tinggi status bar HP agar padding dinamis
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Background Gradient KOTAK (Tanpa Radius)
        Container(
          height: 260 + statusBarHeight, // Tambah tinggi status bar
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_primaryBlue, _darkBlue],
            ),
            // HAPUS borderRadius disini agar jadi kotak
          ),
        ),

        // Hiasan Pattern Transparan (Optional)
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),

        // Konten Profil
        // Kita pakai Padding top sebesar status bar + jarak tambahan
        // Agar teks tidak kena status bar
        Padding(
          padding: EdgeInsets.only(
            top: statusBarHeight + 20, // INI KUNCINYA: Jarak aman dari atas
            left: 20,
            right: 20,
            bottom: 60, // Memberi ruang untuk kartu stats di bawah
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            final user = controller.userProfile;
            final name = user['name'] ?? 'Pengguna Baru';
            final email = user['email'] ?? 'email@contoh.com';
            final role = user['role'] ?? 'Member';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: const Color(0xFFF3F4F6),
                      child: Text(
                        name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: _primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Nama
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 10),
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Radius kecil untuk badge
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12), // Lebih kotak sedikit
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("0", "Voucher"),
          Container(height: 30, width: 1, color: Colors.grey[200]),
          _buildStatItem("0", "Points"),
          Container(height: 30, width: 1, color: Colors.grey[200]),
          _buildStatItem("Silver", "Level"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(
          12,
        ), // Konsisten kotak melengkung sedikit
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
    int? badgeCount,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8), // Icon kotak
                ),
                child: Icon(icon, color: _primaryBlue, size: 20),
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
              if (badgeCount != null && badgeCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[100],
      indent: 72,
      endIndent: 0,
    );
  }
}
