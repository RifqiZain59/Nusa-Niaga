// File: ../controllers/checkout_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nusaniaga/app/modules/payment/views/payment_view.dart';

class CheckoutController extends GetxController {
  // 1. Controller untuk Input
  final customerNameController = TextEditingController();
  final lokasiPemesananController = TextEditingController();

  // 2. State Observable untuk Status Tombol
  var isContinueEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Tambahkan listener yang memanggil validasi setiap kali teks berubah
    customerNameController.addListener(_validateInputs);
    lokasiPemesananController.addListener(_validateInputs);

    // Panggil validasi sekali saat inisialisasi jika ada nilai default
    _validateInputs();
  }

  @override
  void onClose() {
    // Bersihkan controller
    customerNameController.dispose();
    lokasiPemesananController.dispose();
    super.onClose();
  }

  // 3. Logika Validasi
  void _validateInputs() {
    final customerName = customerNameController.text.trim();
    final lokasi = lokasiPemesananController.text.trim();

    // Perbarui status observable: TRUE jika kedua field tidak kosong
    isContinueEnabled.value = customerName.isNotEmpty && lokasi.isNotEmpty;

    // Opsional: Debugging
    // print('Nama: $customerName, Lokasi: $lokasi, Enabled: ${isContinueEnabled.value}');
  }

  // 4. Fungsi Navigasi
  void goToPayment() {
    if (isContinueEnabled.value) {
      // Navigasi ke PaymentView
      Get.to(() => const PaymentView());
    } else {
      // Ini jarang terjadi jika tombol sudah dinonaktifkan,
      // tetapi ini adalah safety check
      Get.snackbar(
        'Perhatian',
        'Mohon isi Nama Pelanggan dan Lokasi Pemesanan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
