import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nusaniaga/app/data/api_service.dart'; // Import API Service

import '../controllers/pesanansaya_controller.dart';
import '../../detailpesanansaya/views/detailpesanansaya_view.dart';

class PesanansayaView extends GetView<PesanansayaController> {
  const PesanansayaView({super.key});

  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF8F9FD);
  static const Color _textDark = Color(0xFF1F2937);

  String formatRupiah(dynamic number) {
    if (number == null) return "Rp 0";
    try {
      double valDouble = double.tryParse(number.toString()) ?? 0;
      int val = valDouble.toInt();
      String str = val.toString();
      RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return "Rp ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}";
    } catch (e) {
      return "Rp 0";
    }
  }

  String formatTanggal(dynamic dateData) {
    if (dateData == null) return "Baru Saja";
    try {
      String dateStr = dateData.toString();
      if (dateStr.contains('T')) return dateStr.split('T')[0];
      return dateStr.split(' ')[0];
    } catch (e) {
      return "Hari ini";
    }
  }

  // Membersihkan format base64 jika kotor
  String cleanBase64(String base64String) {
    if (base64String.contains(',')) {
      return base64String.split(',').last;
    }
    return base64String.replaceAll(RegExp(r'\s+'), '');
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
        if (controller.isLoading.value)
          return const Center(
            child: CircularProgressIndicator(color: _primaryBlue),
          );
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
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => controller.fetchHistory(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh Data"),
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
    String orderId = (item['order_id'] ?? '-').toString();
    if (orderId.length > 20) orderId = "${orderId.substring(0, 15)}...";

    String date = formatTanggal(item['created_at']);
    String status = (item['status'] ?? 'pending').toString().toUpperCase();

    var summary = item['summary'] ?? {};
    var rawGrandTotal = summary['grand_total'] ?? item['final_price'] ?? 0;
    String totalPrice = formatRupiah(rawGrandTotal);

    List rawItems = item['items'] ?? [];
    var firstItem = rawItems.isNotEmpty ? rawItems[0] : {};

    String productName = firstItem['product_name'] ?? 'Item Produk';
    String quantity = (firstItem['qty'] ?? 1).toString();

    // Ambil Product ID untuk request gambar ke server
    String pid = (firstItem['product_id'] ?? firstItem['id'] ?? '').toString();

    // --- LOGIKA GAMBAR (Collection Products via API) ---
    String? imgBase64 = firstItem['image_base64'] ?? item['image_base64'];
    String? imgUrl = firstItem['image_url'] ?? item['image'];

    ImageProvider imageProvider;

    // 1. Coba decode Base64 (jika ada data sisa/kecil)
    if (imgBase64 != null && imgBase64.length > 100) {
      try {
        imageProvider = MemoryImage(base64Decode(cleanBase64(imgBase64)));
      } catch (e) {
        imageProvider = const AssetImage('assets/logo_app/logo2.png');
      }
    }
    // 2. Jika kosong (karena limit), PANGGIL API backend yang membaca collection products
    else {
      // Ambil Base URL dari ApiService, buang '/api' jika ada
      String baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      // URL ini akan membuat backend membaca image_base64 dari products collection
      String finalUrl = "$baseUrl/api/product_image/$pid";
      imageProvider = NetworkImage(finalUrl);
    }

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              Get.to(() => const DetailpesanansayaView(), arguments: item),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order #$orderId",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                        image: imageProvider,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$quantity Barang",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                if (rawItems.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.layers_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "+ ${rawItems.length - 1} item lainnya",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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
}
