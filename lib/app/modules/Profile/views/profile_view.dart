import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

// Import Controller
import '../controllers/profile_controller.dart';

// Import Halaman Lain
import '../../keamananakun/views/keamananakun_view.dart';
import '../../pesanansaya/views/pesanansaya_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  // --- PALET WARNA ---
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF1E40AF);
  static const Color _backgroundColor = Color(0xFFF8F9FD);
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // SOLUSI ERROR "ProfileController not found"
    // Kode ini memaksa aplikasi membuat Controller jika belum ada
    // ==========================================================
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: false);
    }
    // ==========================================================

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        // Mencegah error layout saat keyboard muncul
        resizeToAvoidBottomInset: false,

        body: RefreshIndicator(
          // Panggil fungsi refresh dari controller
          onRefresh: () async {
            if (Get.isRegistered<ProfileController>()) {
              await controller.refreshProfile();
            }
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(), // Scroll effect solid
            child: Column(
              children: [
                // 1. HEADER
                _buildHeader(context),

                // 2. KONTEN MENU
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // KARTU STATISTIK
                        _buildStatsCard(),

                        const SizedBox(height: 24),

                        // === SECTION 1: AKUN ===
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
                              onTap: () {
                                Get.snackbar(
                                  "Info",
                                  "Fitur Alamat segera hadir",
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // === SECTION 2: BELANJA ===
                        _buildSectionTitle('Aktivitas Belanja'),
                        _buildMenuCard(
                          children: [
                            _buildMenuItem(
                              icon: Ionicons.bag_check_outline,
                              title: 'Pesanan Saya',
                              onTap: () =>
                                  Get.to(() => const PesanansayaView()),
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
                              title: 'Ulasan Produk',
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // === TOMBOL LOGOUT ===
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: TextButton(
                            onPressed: () {
                              Get.defaultDialog(
                                title: "Keluar",
                                middleText: "Apakah Anda yakin ingin keluar?",
                                textConfirm: "Ya, Keluar",
                                textCancel: "Batal",
                                confirmTextColor: Colors.white,
                                buttonColor: Colors.red,
                                onConfirm: () {
                                  Get.back(); // Tutup dialog
                                  // Pastikan controller ada sebelum logout
                                  if (Get.isRegistered<ProfileController>()) {
                                    controller.logout();
                                  } else {
                                    // Fallback manual jika controller error
                                    Get.offAllNamed('/login');
                                  }
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFEF2F2),
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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

  Widget _buildHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Background
        Container(
          height: 300 + topPadding,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_primaryBlue, _darkBlue],
            ),
          ),
        ),
        // Dekorasi
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
        Positioned(
          top: 100,
          left: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),

        // Konten User
        Padding(
          padding: EdgeInsets.only(
            top: topPadding + 40,
            bottom: 80,
            left: 20,
            right: 20,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Obx(() {
              // Cek Controller lagi untuk keamanan
              if (!Get.isRegistered<ProfileController>())
                return const SizedBox();

              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final user = controller.userProfile;
              final name = user['name'] ?? 'Guest';
              final email = user['email'] ?? 'guest@app.com';
              final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Obx(() {
        // Cek Controller agar tidak error
        if (!Get.isRegistered<ProfileController>()) return const SizedBox();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(controller.voucherCount.value.toString(), "Voucher"),
            Container(height: 30, width: 1, color: Colors.grey[200]),
            _buildStatItem("${controller.userPoints.value}", "Poin Saya"),
            Container(height: 30, width: 1, color: Colors.grey[200]),
            _buildStatItem(
              "${controller.transactionCount.value}",
              "Total Transaksi",
            ),
          ],
        );
      }),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
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
    );
  }
}
