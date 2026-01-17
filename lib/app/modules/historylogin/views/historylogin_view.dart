import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Wajib untuk Timestamp
import 'package:ionicons/ionicons.dart';
import '../controllers/historylogin_controller.dart';

class HistoryloginView extends GetView<HistoryloginController> {
  const HistoryloginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller jika belum ada
    if (!Get.isRegistered<HistoryloginController>()) {
      Get.put(HistoryloginController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Background abu sangat muda
      appBar: AppBar(
        title: const Text(
          'Riwayat Login',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
          );
        }

        if (controller.historyItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Ionicons.time_outline, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "Belum ada riwayat login",
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLoginHistory,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.historyItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = controller.historyItems[index];
              final data = doc.data() as Map<String, dynamic>;

              return _buildHistoryCard(data);
            },
          ),
        );
      }),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    // Ambil data dari Firestore
    String deviceName = data['device_name'] ?? 'Unknown Device';
    String platform = data['platform'] ?? 'Unknown OS';
    String timeStr = _formatTimestamp(data['login_time']);

    // Tentukan Icon berdasarkan Platform (Opsional)
    IconData deviceIcon = platform.toLowerCase().contains('ios')
        ? Ionicons.logo_apple
        : Ionicons.logo_android;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Device
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // Biru sangat muda
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(deviceIcon, color: const Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(width: 16),

          // Info Device & Waktu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        platform,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        timeStr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "-";
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      // Format: 17 Jan 2026 • 22:17
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
      return "${date.day} ${months[date.month - 1]} ${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    return timestamp.toString();
  }
}
