import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart';
import '../controllers/poin_controller.dart';

class PoinView extends StatelessWidget {
  const PoinView({super.key});

  // Helper Format Tanggal
  String formatDate(String dateStr) {
    if (dateStr.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Injeksi Controller
    final PoinController controller = Get.put(PoinController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        title: const Text(
          'Loyalty Points',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        color: Colors.indigo,
        child: SafeArea(
          child: Stack(
            // Gunakan Stack agar body tidak tertutup FAB
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100), // Space untuk FAB
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. KARTU POIN (HERO SECTION)
                    Obx(() => _buildHeroPointCard(controller.myPoints.value)),

                    const SizedBox(height: 20),

                    // [BARU] TOMBOL SCAN CARD DI BODY (Agar lebih terlihat)
                    _buildScanCardButton(controller),

                    const SizedBox(height: 30),

                    // 2. JUDUL RIWAYAT
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Riwayat Penukaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 3. LIST RIWAYAT
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Colors.indigo,
                            ),
                          ),
                        );
                      }

                      if (controller.redemptionHistory.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Ionicons.time_outline,
                                  size: 60,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Belum ada riwayat penukaran",
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.redemptionHistory.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          var item = controller.redemptionHistory[index];
                          return _buildHistoryItem(item);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // [FIX] TOMBOL SCAN KAMERA (Floating Action Button)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.scanQrCode(),
        backgroundColor: Colors.indigo,
        // Ganti Icon ke Material Icons standard jika Ionicons bermasalah
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text(
          "Scan Bayar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- WIDGET TAMBAHAN: TOMBOL SCAN DI BODY ---
  Widget _buildScanCardButton(PoinController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => controller.scanQrCode(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.indigo.withOpacity(0.1)),
          ),
        ),
        icon: const Icon(Icons.qr_code_scanner, size: 24),
        label: const Text(
          "Scan QR Code (Alternatif)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- WIDGET ITEM HISTORY ---
  Widget _buildHistoryItem(dynamic item) {
    String customerId = item['customer_id'] ?? 'Unknown';
    String desc = item['description'] ?? 'Penukaran';
    int points = int.tryParse(item['points_spent'].toString()) ?? 0;
    String date = formatDate(item['date'] ?? '');

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
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Ionicons.gift_outline,
              color: Colors.red.shade400,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    "ID: $customerId",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '- $points Poin',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.red.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HERO CARD ---
  Widget _buildHeroPointCard(int points) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade800, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Ionicons.sparkles,
                            color: Colors.yellow,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Member Gold",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Ionicons.wallet, color: Colors.white, size: 28),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Poin Anda',
                      style: TextStyle(
                        color: Colors.indigo.shade100,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 42,
                        height: 1.0,
                        letterSpacing: 1.5,
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
}
