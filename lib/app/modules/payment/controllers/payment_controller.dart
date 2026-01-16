import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_service.dart';
import '../../home/views/home_view.dart'; // Untuk redirect setelah sukses

class PaymentController extends GetxController {
  final ApiService _apiService = ApiService();

  // Data dari Checkout
  var grandTotal = 0.0.obs;
  var orderId = "".obs;
  var voucherCode = "".obs;

  // State UI
  var selectedMethod = "Gopay".obs; // Default selected
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      grandTotal.value =
          double.tryParse(Get.arguments['grand_total'].toString()) ?? 0.0;
      orderId.value = Get.arguments['order_id'] ?? "#ORD-000";
      voucherCode.value = Get.arguments['voucher_code'] ?? "";
    }
  }

  void selectMethod(String method) {
    selectedMethod.value = method;
  }

  Future<void> processPayment() async {
    isLoading.value = true;

    // Simulasi delay jaringan
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Panggil API (Kirim data dummy item karena ini contoh)
      // Di aplikasi nyata, Anda oper list items dari CheckoutController ke sini juga
      final result = await _apiService.createTransaction(
        customerId: "user_123", // Harusnya dari ProfileController
        customerName: "Pelanggan App",
        totalAmount: grandTotal.value,
        paymentMethod: selectedMethod.value,
        items: [], // Kirim items jika ada
        voucherCode: voucherCode.value.isNotEmpty ? voucherCode.value : null,
      );

      isLoading.value = false;

      if (result['status'] == 'success' || true) {
        // Force true untuk demo
        _showSuccessDialog();
      } else {
        Get.snackbar("Gagal", "Transaksi gagal diproses");
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Terjadi kesalahan koneksi");
    }
  }

  void _showSuccessDialog() {
    Get.defaultDialog(
      title: "",
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      radius: 20,
      barrierDismissible: false,
      content: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Pembayaran Berhasil!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Pesanan Anda ${orderId.value} telah berhasil dibayar menggunakan ${selectedMethod.value}.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.offAll(() => const HomeView()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Kembali ke Beranda",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
