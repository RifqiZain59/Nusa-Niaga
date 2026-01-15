import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/detailpesanansaya_controller.dart';

class DetailpesanansayaView extends GetView<DetailpesanansayaController> {
  const DetailpesanansayaView({super.key});

  // --- PALET WARNA ---
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF8F9FD);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textGrey = Color(0xFF6B7280);

  // Helper Format Rupiah
  String formatRupiah(dynamic number) {
    if (number == null) return "Rp 0";
    int val =
        int.tryParse(number.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    String str = val.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return "Rp ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}";
  }

  // Helper Format Tanggal
  String formatTanggal(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(dateString);
      List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DetailpesanansayaController>()) {
      Get.put(DetailpesanansayaController());
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
        if (data.isEmpty) {
          return const Center(child: Text("Data transaksi tidak ditemukan"));
        }

        // --- PARSING DATA ---
        String orderId = data['queue_number'] ?? '000';
        String status = data['status'] ?? 'PAID';
        String date = formatTanggal(data['date']);
        String method = data['payment_method'] ?? 'Cash';
        String customer = data['customer_name'] ?? 'User';

        // 1. Ambil Info Meja
        String tableNumber = data['table_number'] ?? 'App Order';

        // 2. Hitung Harga & Diskon
        double finalPrice =
            double.tryParse(data['final_price'].toString()) ?? 0;
        double originalPrice =
            double.tryParse(data['total_price'].toString()) ?? finalPrice;

        // Jika backend tidak kirim total_price, anggap sama dengan finalPrice
        if (originalPrice < finalPrice) originalPrice = finalPrice;

        double discountAmount = originalPrice - finalPrice;
        bool hasDiscount = discountAmount > 0;

        // Config Status UI
        Color statusColor = Colors.green;
        String statusText = "Pembayaran Berhasil";
        IconData statusIcon = Ionicons.checkmark_circle;

        if (status == 'PENDING') {
          statusColor = Colors.orange;
          statusText = "Menunggu Pembayaran";
          statusIcon = Ionicons.time;
        } else if (status == 'CANCELLED') {
          statusColor = Colors.red;
          statusText = "Dibatalkan";
          statusIcon = Ionicons.close_circle;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. STATUS CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: _boxDecoration(),
                child: Column(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 48),
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
                      "Order ID #$orderId",
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

              // 2. ITEM PRODUK
              const Text(
                "Detail Produk",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _boxDecoration(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar Produk
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        controller.getProductImageUrl(
                          data['product_id'].toString(),
                        ),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[200],
                          width: 70,
                          height: 70,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info Produk
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Produk Item",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${data['quantity']} x Barang",
                            style: const TextStyle(
                              color: _textGrey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatRupiah(
                              originalPrice,
                            ), // Tampilkan harga asli per item
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. INFO PEMESAN & MEJA
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
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 12),
                    _buildInfoRow("Metode Bayar", method),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 12),
                    // TAMPILKAN NOMOR MEJA
                    _buildInfoRow("Lokasi / Meja", tableNumber),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. RINCIAN PEMBAYARAN (HARGA & DISKON)
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
                    // Subtotal (Harga Asli)
                    _buildSummaryRow(
                      "Total Harga",
                      formatRupiah(originalPrice),
                    ),
                    const SizedBox(height: 8),

                    _buildSummaryRow("Biaya Layanan", "Rp 0"),
                    const SizedBox(height: 8),

                    // Diskon (Hanya muncul jika ada)
                    if (hasDiscount) ...[
                      _buildSummaryRow(
                        "Diskon",
                        "- ${formatRupiah(discountAmount)}",
                        isGreen: true,
                      ),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 16),

                    // Total Akhir (Yang Dibayar)
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
                          formatRupiah(finalPrice),
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

              const SizedBox(height: 30),

              // Tombol Bantuan
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar("Bantuan", "Menghubungi Customer Service...");
                  },
                  icon: const Icon(Ionicons.help_circle_outline, size: 20),
                  label: const Text("Butuh Bantuan?"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: _primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // --- WIDGET HELPERS ---

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
