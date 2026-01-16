import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nusaniaga/app/data/api_service.dart'; // Import API Service

import '../controllers/detailpesanansaya_controller.dart';

class DetailpesanansayaView extends GetView<DetailpesanansayaController> {
  const DetailpesanansayaView({super.key});

  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF8F9FD);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textGrey = Color(0xFF6B7280);

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
    if (dateData == null) return "-";
    try {
      String s = dateData.toString();
      if (s.contains('T')) return s.split('T')[0];
      return s.split(' ')[0];
    } catch (e) {
      return dateData.toString();
    }
  }

  String cleanBase64(String base64String) {
    if (base64String.contains(',')) return base64String.split(',').last;
    return base64String.replaceAll(RegExp(r'\s+'), '');
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DetailpesanansayaController>()) {
      Get.put(DetailpesanansayaController());
    }
    if (Get.arguments != null) {
      controller.setTransactionData(Get.arguments);
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Rincian Pesanan',
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
        final data = controller.transaction;
        if (data.isEmpty) return const Center(child: Text("Memuat data..."));

        String orderId = (data['order_id'] ?? '-').toString();
        String displayId = orderId.length > 15
            ? "${orderId.substring(0, 15)}..."
            : orderId;
        String status = (data['status'] ?? 'pending').toString().toUpperCase();
        String date = formatTanggal(data['created_at']);
        String customer = data['customer_name'] ?? '-';
        String tableNumber = (data['table_number'] ?? '-').toString();
        String paymentMethod = data['payment_method'] ?? 'Cash';

        var summary = data['summary'] ?? {};
        double subTotal = double.tryParse(summary['sub_total'].toString()) ?? 0;
        double discount = double.tryParse(summary['discount'].toString()) ?? 0;
        double grandTotal =
            double.tryParse(summary['grand_total'].toString()) ?? 0;

        List items = (data['items'] is List) ? data['items'] : [];

        Color statusColor = Colors.green;
        String statusText = "Pembayaran Berhasil";
        IconData statusIcon = Ionicons.checkmark_circle;
        bool isTransactionSuccess =
            (status == 'SUCCESS' || status == 'SELESAI');

        if (status == 'PENDING') {
          statusColor = Colors.orange;
          statusText = "Menunggu Proses";
          statusIcon = Ionicons.time;
        } else if (status == 'CANCELLED' || status == 'BATAL') {
          statusColor = Colors.red;
          statusText = "Dibatalkan";
          statusIcon = Ionicons.close_circle;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: _boxDecoration(),
                child: Column(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 50),
                    const SizedBox(height: 12),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Order ID #$displayId",
                      style: const TextStyle(color: _textGrey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(color: _textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Detail Produk",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              ...items.map((item) {
                String name = item['product_name'] ?? 'Item';
                String pid = (item['product_id'] ?? item['id'] ?? '')
                    .toString();
                String category = item['category'] ?? '-';
                int qty = int.tryParse(item['qty'].toString()) ?? 0;
                double price = double.tryParse(item['price'].toString()) ?? 0;
                bool isReviewed = controller.reviewedProductIds.contains(pid);

                // --- LOGIKA GAMBAR (Collection Products via API) ---
                String? imgBase64 =
                    item['image_base64'] ?? data['image_base64'];
                String? imgUrl = item['image_url'] ?? item['image'];

                ImageProvider imageProvider;
                if (imgBase64 != null && imgBase64.length > 100) {
                  try {
                    imageProvider = MemoryImage(
                      base64Decode(cleanBase64(imgBase64)),
                    );
                  } catch (e) {
                    imageProvider = const AssetImage(
                      'assets/logo_app/logo2.png',
                    );
                  }
                } else {
                  // PANGGIL API BACKEND UNTUK AMBIL GAMBAR DARI COLLECTION PRODUCTS
                  String baseUrl = ApiService.baseUrl.replaceAll('/api', '');
                  String finalUrl = "$baseUrl/api/product_image/$pid";
                  imageProvider = NetworkImage(finalUrl);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: _boxDecoration(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image(
                              image: imageProvider,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: _primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "$qty x ${formatRupiah(price)}",
                                  style: const TextStyle(
                                    color: _textGrey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatRupiah(price * qty),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      if (isTransactionSuccess) ...[
                        const Divider(height: 24),
                        if (isReviewed)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Ulasan Terkirim",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showRatingDialog(context, pid, name, qty),
                              icon: const Icon(
                                Icons.star_rate_rounded,
                                size: 20,
                              ),
                              label: const Text("Beri Ulasan"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.amber[700],
                                side: BorderSide(color: Colors.amber[700]!),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),
              // ... Sisa kode Info Pemesanan & Rincian Pembayaran (Sama) ...
              const Text(
                "Info Pemesanan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _boxDecoration(),
                child: Column(
                  children: [
                    _buildInfoRow("Nama Pemesan", customer),
                    const Divider(height: 24, color: Color(0xFFF3F4F6)),
                    _buildInfoRow("Nomor Meja", tableNumber),
                    const Divider(height: 24, color: Color(0xFFF3F4F6)),
                    _buildInfoRow("Metode Pembayaran", paymentMethod),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Rincian Pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _boxDecoration(),
                child: Column(
                  children: [
                    _buildSummaryRow("Subtotal", formatRupiah(subTotal)),
                    if (discount > 0) ...[
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        "Diskon",
                        "- ${formatRupiah(discount)}",
                        isGreen: true,
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Bayar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formatRupiah(grandTotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: _primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  void _showRatingDialog(
    BuildContext context,
    String productId,
    String productName,
    int qty,
  ) {
    controller.resetReviewForm();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Beri Ulasan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close, color: _textGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Bagaimana pengalamanmu dengan\n$productName?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textGrey, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () =>
                            controller.selectedRating.value = index + 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < controller.selectedRating.value
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: index < controller.selectedRating.value
                                ? Colors.amber[400]
                                : Colors.grey[300],
                            size: 42,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    _getRatingLabel(controller.selectedRating.value),
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.reviewController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Tulis pendapatmu... (Opsional)",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () => controller.submitReview(productId, qty),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Kirim Ulasan",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return "Sangat Buruk";
      case 2:
        return "Kurang Baik";
      case 3:
        return "Cukup";
      case 4:
        return "Bagus";
      case 5:
        return "Sempurna!";
      default:
        return "Ketuk Bintang";
    }
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textGrey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: _textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textGrey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isGreen ? Colors.green : _textDark,
          ),
        ),
      ],
    );
  }
}
