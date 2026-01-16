import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/payment_controller.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  // Warna Konsisten
  static const Color _primaryColor = Color(0xFF2563EB);
  static const Color _bgColor = Color(0xFFF5F7FA);
  static const Color _cardColor = Colors.white;
  static const Color _textDark = Color(0xFF1F2937);

  // Helper Format Rupiah
  String formatRupiah(double number) {
    String str = number.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return "Rp ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    // [PENTING] Injeksi Controller
    final PaymentController controller = Get.put(PaymentController());

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          'Pembayaran',
          style: TextStyle(color: _textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _cardColor,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Total Tagihan Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primaryColor, Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Total Tagihan",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Text(
                            formatRupiah(controller.grandTotal.value),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Obx(
                            () => Text(
                              "Order ID: ${controller.orderId.value}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Pilih Metode Pembayaran",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 2. E-Wallet Section
                  _buildPaymentGroup("E-Wallet", [
                    _paymentOption(
                      controller, // [FIX] Tambahkan controller di sini
                      "Gopay",
                      "assets/icon/gopay.png",
                      isImage: true,
                    ),
                    _paymentOption(
                      controller, // [FIX] Tambahkan controller di sini
                      "ShopeePay",
                      "assets/icon/shopeepay.png",
                      isImage: true,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // 3. Bank Transfer Section
                  _buildPaymentGroup("Transfer & Lainnya", [
                    _paymentOption(
                      controller, // [FIX] Tambahkan controller di sini
                      "BCA Virtual Account",
                      "",
                      icon: Ionicons.card_outline,
                    ),
                    _paymentOption(
                      controller, // [FIX] Tambahkan controller di sini
                      "QRIS",
                      "",
                      icon: Ionicons.qr_code_outline,
                    ),
                    _paymentOption(
                      controller, // [FIX] Tambahkan controller di sini
                      "Tunai / Cash",
                      "",
                      icon: Ionicons.cash_outline,
                    ),
                  ]),

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
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.processPayment(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      shadowColor: _primaryColor.withOpacity(0.4),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Ionicons.lock_closed,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Bayar ${formatRupiah(controller.grandTotal.value)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildPaymentGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Column(children: children),
      ],
    );
  }

  Widget _paymentOption(
    PaymentController controller, // Parameter controller wajib ada
    String name,
    String asset, {
    bool isImage = false,
    IconData? icon,
  }) {
    return Obx(() {
      final isSelected = controller.selectedMethod.value == name;
      return GestureDetector(
        onTap: () => controller.selectMethod(name), // Mengubah state controller
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _primaryColor : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? _primaryColor.withOpacity(0.1)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isImage
                    ? Image.asset(asset, fit: BoxFit.contain)
                    : Icon(icon, color: Colors.black87, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: _textDark,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Ionicons.checkmark_circle,
                  color: _primaryColor,
                  size: 24,
                )
              else
                Icon(Icons.circle_outlined, color: Colors.grey[300], size: 24),
            ],
          ),
        ),
      );
    });
  }
}
