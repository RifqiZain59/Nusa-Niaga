import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  static const Color _primaryColor = Color(0xFF2563EB);
  static const Color _bgColor = Color(0xFFF5F7FA);
  static const Color _cardColor = Colors.white;
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _dangerColor = Color(
    0xFFEF4444,
  ); // Warna Merah untuk Hapus

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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. INFO PEMESAN
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

                  // 2. LOKASI
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

                  // 3. DETAIL ITEM
                  _buildSectionTitle("Detail Item"),
                  Obx(() {
                    if (controller.orderData.isEmpty) return const SizedBox();

                    String img =
                        controller.orderData['image_url'] ??
                        controller.orderData['image'] ??
                        '';
                    String name = controller.orderData['name'] ?? '-';
                    String cat = controller.orderData['category'] ?? 'Menu';

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _boxDecoration(),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              img,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                width: 70,
                                height: 70,
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
                                  "${controller.quantity.value} x ${controller.formatRupiah(controller.itemPrice.value)}",
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

                  // 4. PROMO & VOUCHER (UPDATE: Tombol Hapus/Pakai)
                  _buildSectionTitle("Promo & Voucher"),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: _boxDecoration(),
                    child: Obx(() {
                      final isApplied =
                          controller.isPromoApplied.value; // Cek status promo
                      final isFilled = controller.isPromoFilled.value;

                      return Row(
                        children: [
                          Icon(
                            Ionicons.ticket_outline,
                            color: isApplied ? _primaryColor : Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: controller.promoController,
                              readOnly:
                                  isApplied, // Kunci input jika promo sedang dipakai
                              decoration: InputDecoration(
                                hintText: isApplied
                                    ? 'Promo Digunakan'
                                    : 'Kode Promo (Cth: HEMAT)',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isApplied ? _primaryColor : _textDark,
                              ),
                            ),
                          ),
                          // TOMBOL DINAMIS (HAPUS / PAKAI)
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: isApplied
                                  ? () => controller
                                        .removePromo() // Jika aktif -> Hapus
                                  : (isFilled
                                        ? () => controller.applyPromo()
                                        : null), // Jika tidak -> Pakai (kalau ada isi)

                              style: ElevatedButton.styleFrom(
                                backgroundColor: isApplied
                                    ? _dangerColor // Merah jika tombol Hapus
                                    : (isFilled
                                          ? _primaryColor
                                          : Colors
                                                .grey[300]), // Biru/Abu jika Pakai
                                foregroundColor: (isApplied || isFilled)
                                    ? Colors.white
                                    : Colors.grey,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              child: Text(
                                isApplied ? "Hapus" : "Pakai",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  // 5. RINGKASAN PEMBAYARAN
                  _buildSectionTitle("Ringkasan Pembayaran"),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _boxDecoration(),
                    child: Obx(
                      () => Column(
                        children: [
                          _buildSummaryRow(
                            "Subtotal",
                            controller.formatRupiah(controller.subTotal.value),
                          ),
                          const SizedBox(height: 12),

                          // Baris Diskon
                          _buildSummaryRow(
                            "Diskon",
                            "-${controller.formatRupiah(controller.discount.value)}",
                            isGreen: true,
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1, color: Colors.grey),
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
                              Text(
                                controller.formatRupiah(
                                  controller.grandTotal.value,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: _primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // BOTTOM BAR
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
                final isLoading = controller.isLoading.value;

                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (isEnabled && !isLoading)
                        ? () => controller.processCheckout()
                        : null,
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
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
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
