import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Profile/controllers/profile_controller.dart'; // Import Profile

class CheckoutController extends GetxController {
  // Hanya butuh controller untuk lokasi/meja, nama user diambil otomatis
  final TextEditingController lokasiPemesananController =
      TextEditingController();

  // State Validasi Tombol
  var isContinueEnabled = false.obs;

  // Data Produk
  var orderData = <String, dynamic>{}.obs;

  // Hitungan Biaya
  var itemPrice = 0.0.obs;
  var quantity = 1.obs;
  var subTotal = 0.0.obs;
  var tax = 0.0.obs;
  var grandTotal = 0.0.obs;

  // Data User (Otomatis)
  var userName = "Guest".obs;

  @override
  void onInit() {
    super.onInit();

    // 1. AMBIL NAMA USER DARI PROFILE CONTROLLER
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileCtrl = Get.find<ProfileController>();
        userName.value = profileCtrl.userProfile['name'] ?? "Pelanggan Setia";
      } else {
        // Fallback jika controller belum ada (jarang terjadi flow ini)
        Get.put(ProfileController());
        final profileCtrl = Get.find<ProfileController>();
        userName.value = profileCtrl.userProfile['name'] ?? "Pelanggan Setia";
      }
    } catch (e) {
      userName.value = "Pelanggan";
    }

    // 2. Tangkap Data Produk
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      orderData.assignAll(Get.arguments);
      quantity.value = orderData['quantity'] ?? 1;

      var priceRaw = orderData['price'];
      if (priceRaw is String) {
        String clean = priceRaw.replaceAll(RegExp(r'[^0-9]'), '');
        itemPrice.value = double.tryParse(clean) ?? 0.0;
      } else if (priceRaw is num) {
        itemPrice.value = priceRaw.toDouble();
      }
      calculateTotal();
    }

    // Listener Validasi (Hanya cek lokasi, karena nama sudah otomatis)
    lokasiPemesananController.addListener(_validateForm);
  }

  void calculateTotal() {
    subTotal.value = itemPrice.value * quantity.value;
    tax.value = subTotal.value * 0.11;
    grandTotal.value = subTotal.value + tax.value;
  }

  void _validateForm() {
    // Tombol aktif jika Lokasi terisi (Nama sudah pasti ada)
    isContinueEnabled.value = lokasiPemesananController.text.isNotEmpty;
  }

  void goToPayment() {
    Get.toNamed(
      '/payment',
      arguments: {
        'grand_total': grandTotal.value,
        'order_id':
            '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      },
    );
  }

  @override
  void onClose() {
    lokasiPemesananController.dispose();
    super.onClose();
  }
}
