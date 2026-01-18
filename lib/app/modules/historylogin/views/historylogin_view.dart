import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/historylogin_controller.dart';

class HistoryloginView extends GetView<HistoryloginController> {
  const HistoryloginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller ada
    if (!Get.isRegistered<HistoryloginController>()) {
      Get.put(HistoryloginController());
    }

    // Definisi Warna Tema Lokal
    const Color primaryColor = Color(0xFF2563EB);
    const Color bgColor = Color(0xFFF8FAFC);
    const Color textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Riwayat Login',
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        if (controller.historyItems.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLoginHistory,
          color: primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: controller.historyItems.length,
            itemBuilder: (context, index) {
              final doc = controller.historyItems[index];
              final data = doc.data() as Map<String, dynamic>;

              // Animasi sederhana untuk item (opsional, tapi bagus)
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildHistoryCard(data),
              );
            },
          ),
        );
      }),
    );
  }

  // --- WIDGET KARTU RIWAYAT (SUPERBAGUS) ---
  Widget _buildHistoryCard(Map<String, dynamic> data) {
    String deviceName = data['device_name'] ?? 'Unknown Device';
    String platform = data['platform'] ?? 'System';
    String timeStr = _formatTimestamp(data['login_time']);

    // Deteksi Platform untuk Icon & Warna
    bool isIos =
        platform.toLowerCase().contains('ios') ||
        platform.toLowerCase().contains('iphone');
    bool isAndroid = platform.toLowerCase().contains('android');
    bool isWindows = platform.toLowerCase().contains('windows');

    IconData deviceIcon;
    Color iconColor;
    Color iconBgColor;

    if (isIos) {
      deviceIcon = Ionicons.logo_apple;
      iconColor = Colors.grey[800]!;
      iconBgColor = Colors.grey[200]!;
    } else if (isAndroid) {
      deviceIcon = Ionicons.logo_android;
      iconColor = const Color(0xFF3DDC84); // Android Green
      iconBgColor = const Color(0xFFE8F5E9);
    } else if (isWindows) {
      deviceIcon = Ionicons.logo_windows;
      iconColor = const Color(0xFF0078D4);
      iconBgColor = const Color(0xFFE0F2F1);
    } else {
      deviceIcon = Ionicons.laptop_outline;
      iconColor = const Color(0xFF2563EB);
      iconBgColor = const Color(0xFFEFF6FF);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08), // Shadow halus
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Bisa tambah aksi detail jika perlu
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 1. Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(deviceIcon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),

                // 2. Info Device
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B), // Slate 800
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Baris Platform & Waktu
                      Row(
                        children: [
                          // Badge Platform
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9), // Slate 100
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              isAndroid
                                  ? "Android"
                                  : (isIos ? "iOS" : "Web/PC"),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Waktu
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Ionicons.time_outline,
                                  size: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    timeStr,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Status Indicator (Dot Hijau = Aktif/Sukses)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 4,
                      ),
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

  // --- WIDGET EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Ionicons.shield_checkmark_outline,
              size: 60,
              color: Colors.blue[300],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Belum Ada Aktivitas",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Riwayat login perangkat Anda\nakan muncul di sini.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- FORMATTER TANGGAL ---
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "-";
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      DateTime now = DateTime.now();

      // Cek apakah Hari Ini
      bool isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      String time =
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

      if (isToday) {
        return "Hari ini, $time";
      }

      List<String> months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "Mei",
        "Jun",
        "Jul",
        "Agu",
        "Sep",
        "Okt",
        "Nov",
        "Des",
      ];
      return "${date.day} ${months[date.month - 1]} ${date.year} • $time";
    }
    return timestamp.toString();
  }
}
