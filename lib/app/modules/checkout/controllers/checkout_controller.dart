import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Profile/controllers/profile_controller.dart';
import '../../../data/api_service.dart';

class CheckoutController extends GetxController {
  final ApiService _apiService = ApiService();

  // Input Controllers
  final TextEditingController lokasiPemesananController =
      TextEditingController();
  final TextEditingController promoController = TextEditingController();

  // State UI
  var isContinueEnabled = false.obs;
  var isPromoEmpty = true.obs; // Untuk mengubah warna tombol voucher
  var userName = "Guest".obs;

  // Data Produk
  var orderData = <String, dynamic>{}.obs;

  // Hitungan Biaya
  var itemPrice = 0.0.obs;
  var quantity = 1.obs;
  var subTotal = 0.0.obs;
  var tax = 0.0.obs; // Pajak 0% sesuai request
  var discount = 0.0.obs;
  var grandTotal = 0.0.obs;

  // Status Voucher
  var isVoucherApplied = false.obs;
  var appliedVoucherCode = "".obs;

  @override
  void onInit() {
    super.onInit();

    // 1. Ambil Nama User dari Profile (Otomatis)
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileCtrl = Get.find<ProfileController>();
        userName.value = profileCtrl.userProfile['name'] ?? "Pelanggan";
      } else {
        Get.put(ProfileController());
        final profileCtrl = Get.find<ProfileController>();
        userName.value = profileCtrl.userProfile['name'] ?? "Pelanggan";
      }
    } catch (e) {
      userName.value = "Pelanggan";
    }

    // 2. Tangkap Data Produk dari Halaman Sebelumnya
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      orderData.assignAll(Get.arguments);
      quantity.value = orderData['quantity'] ?? 1;

      // Parsing Harga
      var priceRaw = orderData['price'];
      if (priceRaw is String) {
        String clean = priceRaw.replaceAll(RegExp(r'[^0-9]'), '');
        itemPrice.value = double.tryParse(clean) ?? 0.0;
      } else if (priceRaw is num) {
        itemPrice.value = priceRaw.toDouble();
      }

      calculateTotal();
    }

    // 3. Listener Validasi Input
    lokasiPemesananController.addListener(() {
      // Tombol lanjut aktif hanya jika lokasi diisi
      isContinueEnabled.value = lokasiPemesananController.text.isNotEmpty;
    });

    // 4. Listener Input Promo (Untuk warna tombol)
    promoController.addListener(() {
      isPromoEmpty.value = promoController.text.trim().isEmpty;
    });
  }

  void calculateTotal() {
    subTotal.value = itemPrice.value * quantity.value;
    tax.value = 0; // Pajak dinonaktifkan

    // Pastikan diskon tidak minus
    double finalDiscount = discount.value;
    if (finalDiscount > subTotal.value) {
      finalDiscount = subTotal.value;
    }

    grandTotal.value = subTotal.value + tax.value - finalDiscount;
  }

  Future<void> applyVoucher() async {
    String code = promoController.text.trim();
    if (code.isEmpty) return;

    // Tutup keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    Get.showOverlay(
      asyncFunction: () async {
        int discountAmount = await _apiService.checkVoucherValidity(code);

        if (discountAmount > 0) {
          discount.value = discountAmount.toDouble();
          isVoucherApplied.value = true;
          appliedVoucherCode.value = code.toUpperCase();
          calculateTotal();
          Get.snackbar(
            "Berhasil",
            "Voucher diterapkan! Hemat Rp $discountAmount",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        } else {
          discount.value = 0;
          isVoucherApplied.value = false;
          appliedVoucherCode.value = "";
          calculateTotal();
          Get.snackbar(
            "Gagal",
            "Kode voucher tidak valid atau kadaluarsa",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      },
      loadingWidget: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  // Hapus Voucher (Opsional, jika tombol pakai ditekan lagi saat sudah aktif)
  void removeVoucher() {
    discount.value = 0;
    isVoucherApplied.value = false;
    appliedVoucherCode.value = "";
    promoController.clear();
    calculateTotal();
  }

  void goToPayment() {
    // Generate Order ID Unik (Misal: #ORD-timestamp)
    String newOrderId =
        '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    Get.toNamed(
      '/payment',
      arguments: {
        'grand_total': grandTotal.value,
        'order_id': newOrderId,
        'voucher_code': isVoucherApplied.value
            ? appliedVoucherCode.value
            : null,

        // PENTING: Kirim data detail produk ke Payment
        'product_id': orderData['id'],
        'product_name': orderData['name'],
        'quantity': quantity.value,
        'location': lokasiPemesananController.text, // Kirim lokasi meja
        'customer_name': userName.value,
      },
    );
  }

  @override
  void onClose() {
    lokasiPemesananController.dispose();
    promoController.dispose();
    super.onClose();
  }
}
