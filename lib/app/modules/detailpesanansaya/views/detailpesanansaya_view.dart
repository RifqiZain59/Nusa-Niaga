import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/detailpesanansaya_controller.dart';

class DetailpesanansayaView extends GetView<DetailpesanansayaController> {
  const DetailpesanansayaView({super.key});

  // --- STYLE ---
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF8F9FD);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textGrey = Color(0xFF6B7280);

  // Helper Format Rupiah
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

  // Helper Tanggal
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
    // Inject Controller jika belum ada
    if (!Get.isRegistered<DetailpesanansayaController>()) {
      Get.put(DetailpesanansayaController());
    }

    // Ambil arguments jika controller belum punya data
    // Ini penting jika controller di-recreate
    if (controller.transaction.isEmpty && Get.arguments != null) {
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
        // PERBAIKAN: Ambil data dari Observable
        final data = controller.transaction;

        // Jika data masih kosong, tampilkan loading atau pesan error
        if (data.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: _primaryBlue),
                SizedBox(height: 10),
                Text("Memuat data transaksi..."),
              ],
            ),
          );
        }

        // --- PARSING DATA ---
        String orderId = data['queue_number']?.toString() ?? '-';
        String status = (data['status'] ?? 'PAID').toString().toUpperCase();
        String date = formatTanggal(data['date']);
        String method = data['payment_method'] ?? 'Cash';
        String customer = data['customer_name'] ?? 'Pelanggan';
        String tableNumber = data['table_number'] ?? '-';

        int quantity = int.tryParse(data['quantity'].toString()) ?? 1;

        // --- HITUNG HARGA ---
        double grandTotal =
            double.tryParse(data['final_price'].toString()) ?? 0;
        double subTotal = double.tryParse(data['total_price'].toString()) ?? 0;
        if (subTotal == 0) subTotal = grandTotal;

        double discountAmount = subTotal - grandTotal;
        if (discountAmount < 0) discountAmount = 0;
        bool hasDiscount = discountAmount > 100;

        // --- STATUS UI ---
        Color statusColor = Colors.green;
        String statusText = "Pembayaran Berhasil";
        IconData statusIcon = Ionicons.checkmark_circle;

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
              // HEADER STATUS
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

              // DETAIL PRODUK
              const Text(
                "Detail Produk",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _boxDecoration(),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: Image.network(
                          controller.getProductImageUrl(
                            data['product_id'].toString(),
                          ),
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(
                            Ionicons.image_outline,
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
                          const Text(
                            "Produk Item", // Bisa diganti data['product_name'] jika ada
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$quantity x Barang",
                            style: const TextStyle(
                              color: _textGrey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatRupiah(subTotal),
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

              // INFO PEMESANAN
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
                    _buildInfoRow("Lokasi / Meja", tableNumber),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // RINCIAN HARGA
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
                    const SizedBox(height: 8),
                    _buildSummaryRow("Pajak / Layanan", "Rp 0"),

                    if (hasDiscount) ...[
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        "Diskon Voucher",
                        "- ${formatRupiah(discountAmount)}",
                        isGreen: true,
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 16),

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
