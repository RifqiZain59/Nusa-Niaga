import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/home_view.dart';

class PaymentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data dari Halaman Checkout
  var grandTotal = 0.0.obs;
  var orderId = "".obs;

  // State UI
  var selectedMethod = "".obs; // Default kosong agar user memilih
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil Data dari Arguments (dikirim dari Checkout)
    if (Get.arguments != null) {
      orderId.value = Get.arguments['order_id'] ?? "";
      grandTotal.value =
          double.tryParse(Get.arguments['grand_total'].toString()) ?? 0.0;

      // Jika di checkout sudah pilih metode, set sebagai default
      if (Get.arguments['transaction_data'] != null) {
        var data = Get.arguments['transaction_data'];
        if (data['payment_method'] != null) {
          selectedMethod.value = data['payment_method'];
        }
      }
    }
  }

  // Fungsi ganti pilihan di UI
  void selectMethod(String method) {
    selectedMethod.value = method;
  }

  // --- PROSES PEMBAYARAN (UPDATE DATABASE) ---
  Future<void> processPayment() async {
    // 1. Validasi
    if (selectedMethod.value.isEmpty) {
      Get.snackbar(
        "Pilih Metode",
        "Silakan pilih metode pembayaran terlebih dahulu.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (orderId.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Order ID tidak valid.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // 2. UPDATE Firestore (Bukan Create Baru)
      // Kita cari dokumen transaksi berdasarkan Order ID yang sudah dibuat di checkout
      await _firestore.collection('transactions').doc(orderId.value).update({
        'payment_method': selectedMethod.value, // Simpan metode pembayaran
        'status': 'success', // Ubah status jadi sukses/lunas
        'paid_at': DateTime.now().toIso8601String(),
      });

      isLoading.value = false;

      // 3. Tampilkan Dialog Sukses
      _showSuccessDialog();
    } catch (e) {
      isLoading.value = false;
      print("Error payment: $e");
      Get.snackbar(
        "Gagal",
        "Terjadi kesalahan sistem: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
            "Pesanan ${orderId.value} lunas via ${selectedMethod.value}.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Reset ke Home dan hapus history halaman sebelumnya
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
