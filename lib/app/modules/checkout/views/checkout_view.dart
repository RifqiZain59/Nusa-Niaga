import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  // --- PALET WARNA ---
  static const Color _primaryColor = Color(0xFF2563EB); // Biru Modern
  static const Color _bgColor = Color(0xFFF5F7FA); // Abu-abu sangat muda
  static const Color _cardColor = Colors.white;
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textGrey = Color(0xFF6B7280);

  // Helper Format Rupiah
  String formatRupiah(double number) {
    String str = number.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return "Rp ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CheckoutController>()) {
      Get.put(CheckoutController());
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _cardColor,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: _textDark),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _textDark,
          ),
        ),
      ),
      body: Column(
        children: [
          // KONTEN SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SECTION INFO PEMESAN (OTOMATIS)
                  _buildSectionTitle("Informasi Pemesan"),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Ionicons.person,
                            color: _primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nama Pemesan",
                                style: TextStyle(
                                  color: _textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // DATA OTOMATIS DARI CONTROLLER
                              Obx(
                                () => Text(
                                  controller.userName.value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Ionicons.checkmark_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. SECTION LOKASI MEJA (INPUT)
                  _buildSectionTitle("Lokasi Pengantaran"),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        const Icon(Ionicons.location_outline, color: _textGrey),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: controller.lokasiPemesananController,
                            decoration: const InputDecoration(
                              hintText: 'Nomor Meja / Area (Cth: Meja 5)',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. SECTION ITEM PRODUK
                  _buildSectionTitle("Detail Item"),
                  Obx(() {
                    if (controller.orderData.isEmpty) return const SizedBox();

                    String img =
                        controller.orderData['image_url'] ??
                        controller.orderData['image'] ??
                        '';
                    String name = controller.orderData['name'] ?? '-';
                    String cat =
                        controller.orderData['category'] ??
                        controller.orderData['type'] ??
                        'Menu';

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _boxDecoration(),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: img.startsWith('http')
                                ? Image.network(
                                    img,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[200],
                                    ),
                                  )
                                : Image.asset(
                                    img,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[200],
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
                                    fontSize: 16,
                                    color: _textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat,
                                  style: const TextStyle(
                                    color: _textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${controller.quantity.value} x ${formatRupiah(controller.itemPrice.value)}",
                                  style: const TextStyle(
                                    color: _primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // 4. SECTION VOUCHER
                  _buildSectionTitle("Promo & Voucher"),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        const Icon(
                          Ionicons.ticket_outline,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Gunakan / masukkan kode promo",
                            style: TextStyle(color: _textGrey, fontSize: 14),
                          ),
                        ),
                        Icon(Ionicons.chevron_forward, color: Colors.grey[300]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. SECTION RINGKASAN PEMBAYARAN (STRUK)
                  _buildSectionTitle("Ringkasan Pembayaran"),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _boxDecoration(),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          "Subtotal",
                          formatRupiah(controller.subTotal.value),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          "Pajak (11%)",
                          formatRupiah(controller.tax.value),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow("Diskon", "-Rp 0", isGreen: true),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            color: Colors.grey,
                          ), // Garis putus-putus lookalike
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Pembayaran",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Obx(
                              () => Text(
                                formatRupiah(controller.grandTotal.value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: _primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ), // Spacer agar tidak tertutup tombol
                ],
              ),
            ),
          ),

          // BOTTOM BAR (STICKY)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Obx(() {
                final isEnabled = controller.isContinueEnabled.value;
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isEnabled ? controller.goToPayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEnabled
                          ? _primaryColor
                          : Colors.grey[300],
                      foregroundColor: isEnabled
                          ? Colors.white
                          : Colors.grey[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: isEnabled ? 5 : 0,
                      shadowColor: _primaryColor.withOpacity(0.4),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Lanjut Pembayaran",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Ionicons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: _cardColor,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _textDark,
        ),
      ),
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
            color: isGreen ? Colors.green : _textDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
