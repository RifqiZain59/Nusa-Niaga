import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

// Import Controller
import '../controllers/pesanansaya_controller.dart';

// Import Halaman Detail
import '../../detailpesanansaya/views/detailpesanansaya_view.dart';

class PesanansayaView extends GetView<PesanansayaController> {
  const PesanansayaView({super.key});

  // --- STYLE KONSTAN ---
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF8F9FD);
  static const Color _textDark = Color(0xFF1F2937);

  // Helper Format Rupiah (DIPERBAIKI: Aman untuk Double/Float)
  String formatRupiah(dynamic number) {
    if (number == null) return "Rp 0";
    try {
      // 1. Parse ke double dulu untuk menangani desimal (contoh: 15000.0)
      double valDouble = double.tryParse(number.toString()) ?? 0;

      // 2. Ubah ke Int (hilangkan koma)
      int val = valDouble.toInt();

      // 3. Format ribuan
      String str = val.toString();
      RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return "Rp ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}";
    } catch (e) {
      return "Rp 0";
    }
  }

  // Helper Format Tanggal (DD-MM-YYYY)
  String formatTanggal(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Hari ini";
    try {
      DateTime dt = DateTime.parse(dateString);
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString();
      return "$day-$month-$year";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PesanansayaController>()) {
      Get.put(PesanansayaController());
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _primaryBlue),
          );
        }

        if (controller.allTransactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Ionicons.receipt_outline,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  "Belum ada transaksi",
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchHistory(),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.allTransactions.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (ctx, index) {
              final item = controller.allTransactions[index];
              return _buildOrderCard(item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> item) {
    // --- PARSING DATA ---
    String orderId = item['queue_number'] ?? '000';
    String date = formatTanggal(item['date']);
    String status = (item['status'] ?? 'PAID').toString().toUpperCase();

    // DIPERBAIKI: Ambil harga dengan aman
    // Prioritas: final_price -> total_price -> 0
    var rawPrice = item['final_price'] ?? item['total_price'] ?? 0;
    String totalPrice = formatRupiah(rawPrice);

    // Gambar Produk
    String productId = item['product_id']?.toString() ?? '';
    String imageUrl = controller.apiService.getProductImageUrl(productId);

    // Konfigurasi Status
    Color statusColor = Colors.green;
    String statusText = "Selesai";
    Color bgStatusColor = Colors.green.withOpacity(0.1);

    if (status == 'PENDING') {
      statusColor = Colors.orange;
      statusText = "Diproses";
      bgStatusColor = Colors.orange.withOpacity(0.1);
    } else if (status == 'CANCELLED' || status == 'BATAL') {
      statusColor = Colors.red;
      statusText = "Dibatalkan";
      bgStatusColor = Colors.red.withOpacity(0.1);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // === HEADER KARTU ===
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #$orderId",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bgStatusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // === BODY KARTU ===
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Gambar Produk
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[100],
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Ionicons.image_outline,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Info Item
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Produk Item", // Nama produk statis
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${item['quantity']} Barang",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      // HARGA YANG SUDAH DIPERBAIKI
                      Text(
                        totalPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // === FOOTER ACTION ===
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.to(() => const DetailpesanansayaView(), arguments: item);
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  "Lihat Detail Transaksi",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
