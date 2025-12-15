// File: ../views/checkout_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  // Widget Input Teks Pelanggan
  Widget _buildCustomerInput() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Color(0xFF1E2B4B)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              // 💡 Terapkan controller
              controller: controller.customerNameController,
              enabled: true,
              decoration: const InputDecoration(
                hintText: 'Customers Name',
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Pilih Meja/Lokasi
  Widget _buildTableSelect() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Color(0xFF1E2B4B)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              // 💡 Terapkan controller
              controller: controller.lokasiPemesananController,
              enabled: true,
              decoration: const InputDecoration(
                hintText: 'Lokasi Pemesanan',
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Input Promo Code
  Widget _buildPromoCodeInput() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(
              Icons.percent_outlined,
              color: Color(0xFF1E2B4B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Promo code',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Apply',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Kartu Item Pesanan
  Widget _buildOrderItemCard({
    required String imagePath,
    required String title,
    required String description,
    required String price,
    required int quantity,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1E2B4B),
                        ),
                      ),
                      _buildQuantityControl(quantity),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Kontrol Kuantitas (Tidak Berubah)
  Widget _buildQuantityControl(int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            isMinus: true,
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1E2B4B),
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            isMinus: false,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // Widget Tombol Kuantitas (Tidak Berubah)
  Widget _buildQuantityButton({
    required IconData icon,
    required bool isMinus,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isMinus ? Colors.grey.shade300 : const Color(0xFF1E2B4B),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isMinus ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  // Widget Ringkasan Pembayaran
  Widget _buildPaymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2B4B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const Text(
              '\$9.50',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tax',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const Text(
              '\$0.50',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const Divider(height: 30, thickness: 1, color: Colors.grey),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Grand Total',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              '\$10.00',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2B4B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.white;

    // Pastikan controller tersedia. (Sebaiknya gunakan Get.put di Binding)
    if (!Get.isRegistered<CheckoutController>()) {
      Get.put(CheckoutController());
    }

    // Ambil controller setelah dipastikan ada
    final ctrl = Get.find<CheckoutController>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2B4B)),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          'Order #8726AB',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF1E2B4B),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                _buildCustomerInput(),
                const SizedBox(height: 12),
                _buildTableSelect(),
                const SizedBox(height: 30),
                const Text(
                  'Orders',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2B4B),
                  ),
                ),
                const SizedBox(height: 12),
                _buildOrderItemCard(
                  imagePath: 'assets/whole_wheat_loaf.png',
                  title: 'Whole Wheat Loaf',
                  description: 'Nutritious, fiber-rich, and wholesome loaves.',
                  price: '\$4.50',
                  quantity: 1,
                ),
                _buildOrderItemCard(
                  imagePath: 'assets/frosted_bliss_donut.png',
                  title: 'Frosted Bliss Donut',
                  description:
                      'Soft blue donut with vibrant pink sprinkles delight.',
                  price: '\$5.50',
                  quantity: 1,
                ),
                const SizedBox(height: 30),
                _buildPromoCodeInput(),
                _buildPaymentSummary(),
                const SizedBox(height: 120),
              ],
            ),

            // 👇 Tombol "Continue" dengan Validasi Kondisional
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Obx(() {
                  // 👈 Obx untuk bereaksi terhadap perubahan state
                  final isEnabled = ctrl.isContinueEnabled.value;
                  final buttonColor = isEnabled
                      ? const Color(0xFF1E2B4B)
                      : Colors.grey; // Warna non-aktif

                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      // onPressed: Panggil goToPayment jika diaktifkan, jika tidak, null
                      onPressed: isEnabled ? ctrl.goToPayment : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor, // Gunakan warna dinamis
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
