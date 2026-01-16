import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nusaniaga/app/data/api_service.dart';
import '../../Profile/controllers/profile_controller.dart';

class CheckoutController extends GetxController {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- INPUT CONTROLLER ---
  final TextEditingController lokasiPemesananController =
      TextEditingController();
  final TextEditingController promoController = TextEditingController();

  // --- VARIABLES ---
  var isContinueEnabled = false.obs;
  var isPromoFilled = false.obs;
  var isPromoApplied =
      false.obs; // <--- STATUS BARU: Cek apakah promo sedang dipakai
  var isLoading = false.obs;

  // --- DATA ---
  var availableVouchers = <dynamic>[].obs;
  var orderData = <String, dynamic>{}.obs;

  // --- HARGA ---
  var itemPrice = 0.0.obs;
  var quantity = 1.obs;
  var subTotal = 0.0.obs;
  var discount = 0.0.obs;
  var grandTotal = 0.0.obs;

  // --- USER INFO ---
  var userName = "Guest".obs;
  var userId = "".obs;

  @override
  void onInit() {
    super.onInit();

    lokasiPemesananController.addListener(_validateForm);
    promoController.addListener(() {
      isPromoFilled.value = promoController.text.isNotEmpty;
    });

    _loadUserData();
    _loadInitialOrderData();
    _fetchVouchersFromApi();
  }

  // --- 1. LOAD DATA ---
  void _loadInitialOrderData() {
    if (Get.arguments != null) {
      orderData.assignAll(Get.arguments);
      quantity.value = orderData['quantity'] ?? 1;

      var p = orderData['price'];
      if (p is String) {
        String clean = p.replaceAll(RegExp(r'[^0-9]'), '');
        itemPrice.value = double.tryParse(clean) ?? 0.0;
      } else if (p is num) {
        itemPrice.value = p.toDouble();
      }

      calculateTotal();

      if (orderData['id'] != null) {
        _fetchProductDetail(orderData['id'].toString());
      }
    }
  }

  void _fetchProductDetail(String productId) async {
    try {
      var doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data()!;
        orderData['category'] = data['category'] ?? 'Umum';
        orderData['name'] = data['name'];
        orderData['image_base64'] = data['image_base64'];
        orderData.refresh();
      }
    } catch (e) {
      print("Gagal ambil detail produk: $e");
    }
  }

  void _fetchVouchersFromApi() async {
    try {
      var vouchers = await _apiService.getVouchers();
      availableVouchers.assignAll(vouchers);
    } catch (e) {
      print("Error load voucher: $e");
    }
  }

  // --- 2. LOGIKA PROMO (UPDATE) ---
  void applyPromo() {
    String inputCode = promoController.text.trim().toUpperCase();
    discount.value = 0.0;

    if (inputCode.isEmpty) return;

    var foundVoucher = availableVouchers.firstWhereOrNull((v) {
      String serverCode = (v['code'] ?? '').toString().toUpperCase();
      return serverCode == inputCode;
    });

    if (foundVoucher != null) {
      var rawAmount = foundVoucher['discount_amount'];
      double promoAmount = double.tryParse(rawAmount.toString()) ?? 0.0;

      if (promoAmount > 0) {
        discount.value = promoAmount;
        isPromoApplied.value = true; // <--- Set Promo Aktif
        Get.snackbar(
          "Berhasil",
          "Potongan Rp ${formatRupiah(promoAmount)} diterapkan!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Gagal",
          "Voucher valid tapi nominal 0",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } else if (inputCode == 'HEMAT') {
      discount.value = 5000.0;
      isPromoApplied.value = true; // <--- Set Promo Aktif
      Get.snackbar(
        "Info",
        "Kode Test HEMAT Berhasil!",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Gagal",
        "Kode voucher tidak valid",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    calculateTotal();
  }

  // --- 3. HAPUS PROMO (BARU) ---
  void removePromo() {
    promoController.clear(); // Kosongkan text field
    discount.value = 0.0; // Reset diskon
    isPromoApplied.value = false; // Set status tidak aktif
    calculateTotal(); // Hitung ulang harga normal
    Get.snackbar(
      "Info",
      "Penggunaan voucher dibatalkan",
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // --- 4. HITUNG TOTAL ---
  void calculateTotal() {
    subTotal.value = itemPrice.value * quantity.value;
    double total = subTotal.value - discount.value;
    grandTotal.value = total < 0 ? 0 : total;
  }

  // --- 5. CHECKOUT ---
  Future<void> processCheckout() async {
    if (grandTotal.value <= 0 && discount.value == 0 && itemPrice.value > 0)
      return;
    isLoading.value = true;

    try {
      String orderId = 'TRX-${DateTime.now().millisecondsSinceEpoch}';

      Map<String, dynamic> trxData = {
        'order_id': orderId,
        'user_id': userId.value,
        'customer_name': userName.value,
        'table_number': lokasiPemesananController.text,
        'items': [
          {
            'product_id': orderData['id'],
            'product_name': orderData['name'],
            'category': orderData['category'] ?? 'Umum',
            'price': itemPrice.value,
            'qty': quantity.value,
            'image': orderData['image_url'] ?? orderData['image'],
          },
        ],
        'summary': {
          'sub_total': subTotal.value,
          'tax': 0,
          'discount': discount.value,
          'grand_total': grandTotal.value,
        },
        'voucher_code': isPromoApplied.value
            ? promoController.text
            : null, // Hanya kirim jika aktif
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('transactions').doc(orderId).set(trxData);

      Get.toNamed(
        '/payment',
        arguments: {
          'grand_total': grandTotal.value,
          'order_id': orderId,
          'transaction_data': trxData,
        },
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal checkout: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _loadUserData() {
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profile = Get.find<ProfileController>().userProfile;
        userName.value = profile['name'] ?? "Pelanggan";
        userId.value = profile['id'] ?? "";
      } else {
        Get.put(ProfileController());
        final profile = Get.find<ProfileController>().userProfile;
        userName.value = profile['name'] ?? "Pelanggan";
        userId.value = profile['id'] ?? "";
      }
    } catch (_) {
      userName.value = "Pelanggan";
    }
  }

  void _validateForm() {
    isContinueEnabled.value = lokasiPemesananController.text.isNotEmpty;
  }

  String formatRupiah(double number) {
    String str = number.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return "Rp ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}";
  }

  @override
  void onClose() {
    lokasiPemesananController.dispose();
    promoController.dispose();
    super.onClose();
  }
}
