import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import ini
import '../../../data/api_service.dart';
import '../../home/views/home_view.dart';

class PaymentController extends GetxController {
  final ApiService _apiService = ApiService();

  var grandTotal = 0.0.obs;
  var orderId = "".obs;
  var voucherCode = "".obs;
  var productId = "".obs;
  var quantity = 0.obs;
  var location = "".obs;

  // Data User
  var customerName = "".obs;
  var customerId = "".obs; // Variable baru untuk ID

  var selectedMethod = "Gopay".obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData(); // Load ID User saat init

    if (Get.arguments != null && Get.arguments is Map) {
      grandTotal.value =
          double.tryParse(Get.arguments['grand_total'].toString()) ?? 0.0;
      orderId.value = Get.arguments['order_id'] ?? "#ORD-000";
      voucherCode.value = Get.arguments['voucher_code'] ?? "";
      productId.value = Get.arguments['product_id']?.toString() ?? "";
      quantity.value = int.tryParse(Get.arguments['quantity'].toString()) ?? 1;
      location.value = Get.arguments['location'] ?? "-";
    }
  }

  // Ambil ID User dari Penyimpanan Lokal
  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    customerId.value = prefs.getString('user_id') ?? "Guest";
    customerName.value = prefs.getString('user_name') ?? "Guest";
  }

  void selectMethod(String method) {
    selectedMethod.value = method;
  }

  Future<void> processPayment() async {
    isLoading.value = true;
    try {
      List<Map<String, dynamic>> items = [];
      if (productId.value.isNotEmpty) {
        items.add({'id': productId.value, 'qty': quantity.value});
      }

      final result = await _apiService.createTransaction(
        customerId: customerId.value, // KIRIM ID ASLI (Bukan Nama)
        customerName: customerName.value,
        totalAmount: grandTotal.value,
        paymentMethod: selectedMethod.value,
        items: items,
        voucherCode: voucherCode.value.isNotEmpty ? voucherCode.value : null,
        tableNumber: location.value,
      );

      isLoading.value = false;

      if (result['status'] == 'success') {
        _showSuccessDialog();
      } else {
        Get.snackbar("Gagal", result['message'] ?? "Transaksi gagal");
      }
    } catch (e) {
      isLoading.value = false;
      print("Error: $e");
      Get.snackbar("Error", "Terjadi kesalahan koneksi");
    }
  }

  // ... (Kode _showSuccessDialog sama seperti sebelumnya) ...
  void _showSuccessDialog() {
    Get.defaultDialog(
      title: "",
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Poin berhasil ditambahkan ke akun Anda.\nMohon tunggu di ${location.value}.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Get.offAll(() => const HomeView()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
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
