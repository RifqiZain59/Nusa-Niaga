import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  // Warna-warna yang digunakan
  static const Color _primaryColor = Color(
    0xFF2563EB,
  ); // Warna biru yang akan digunakan untuk semua ikon utama & role badge
  static const Color _iconBackground = Color(0xFFEDF2F6);
  static const Color _primaryText = Color(0xFF333333);
  static const Color _secondaryText = Color(0xFF777777);
  // Warna Icon Utama Sekarang menggunakan _primaryColor
  static const Color _blueIconColor = _primaryColor;
  // Warna Background Utama
  static const Color _newBackground = Color(0xFFE9ECF3);

  // Widget pembantu untuk item pengaturan
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    Widget tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _iconBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _blueIconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: _primaryText,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Ionicons.chevron_forward,
          size: 18,
          color: _secondaryText,
        ),
        onTap: onTap,
      ),
    );

    if (!isLast) {
      return Column(
        children: [
          tile,
          const Divider(
            height: 1,
            color: Color(0xFFE5E7EB),
            indent: 72,
            endIndent: 16,
          ),
        ],
      );
    }
    return tile;
  }

  // Widget pembantu untuk header bagian (Section Header)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 10.0, bottom: 2.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _primaryText,
        ),
      ),
    );
  }

  // Widget pembungkus kustom untuk daftar pengaturan
  Widget _buildSettingsBox({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }

  // Widget pembungkus kustom untuk header profil
  Widget _buildProfileHeaderBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gambar Profil
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFF1F1F1),
              child: Icon(
                Ionicons.person_circle,
                size: 60,
                color: _secondaryText,
              ),
              // backgroundImage: AssetImage('assets/gweeny.jpg'),
            ),
            const SizedBox(width: 16),
            // Info Pengguna
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gweeny Addams',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryText,
                    ),
                  ),
                  Text(
                    'gweenyaddms@gmail.com',
                    style: TextStyle(fontSize: 14, color: _secondaryText),
                  ),
                ],
              ),
            ),
            // Tombol Posisi/Role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Pembeli',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _newBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeaderBox(),

              // === PENGATURAN AKUN ===
              _buildSectionHeader('Pengaturan Akun'),
              _buildSettingsBox(
                children: [
                  // ITEM: Keamanan Akun
                  _buildSettingItem(
                    icon: Ionicons.lock_closed_outline,
                    title: 'Keamanan Akun',
                  ),
                  // ITEM: Alamat Pengiriman
                  _buildSettingItem(
                    icon: Ionicons.location_outline,
                    title: 'Alamat Pengiriman',
                    isLast: true,
                  ),
                  // HAPUS: Kelola Akun
                ],
              ),

              // === AKTIVITAS BELANJA ===
              _buildSectionHeader('Aktivitas Belanja'),
              _buildSettingsBox(
                children: [
                  // ITEM: Pesanan Saya
                  _buildSettingItem(
                    icon: Ionicons.bag_check_outline,
                    title: 'Pesanan Saya',
                  ),
                  // ITEM: Favorit (Wishlist)
                  _buildSettingItem(
                    icon: Ionicons.heart_outline,
                    title: 'Favorit (Wishlist)',
                  ),
                  // HAPUS: Metode Pembayaran
                  // HAPUS: Pengaturan Notifikasi
                  // ITEM: Tulis Ulasan
                  _buildSettingItem(
                    icon: Ionicons.chatbox_ellipses_outline,
                    title: 'Tulis Ulasan',
                  ),
                  // ITEM: Pusat Bantuan
                  _buildSettingItem(
                    icon: Ionicons.help_circle_outline,
                    title: 'Pusat Bantuan',
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
