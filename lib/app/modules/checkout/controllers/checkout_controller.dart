import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nusaniaga/app/data/api_service.dart';

// Import ProfileController
import '../../Profile/controllers/profile_controller.dart';

class CheckoutController extends GetxController {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- INPUT CONTROLLERS ---
  final TextEditingController lokasiPemesananController =
      TextEditingController();
  final TextEditingController promoController = TextEditingController();

  // --- STATE VARIABLES ---
  var isContinueEnabled = false.obs;
  var isPromoFilled = false.obs;
  var isPromoApplied = false.obs;
  var isLoading = false.obs;

  // Variabel Metode Pembayaran
  var selectedPaymentMethod = 'Cash'.obs;

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
  var userName = "Loading...".obs;
  var userId = "".obs;

  // [BARU] Simpan base64 lokal untuk UI saja, tidak dikirim ke API
  String? _localImageBase64;

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

  void changePaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  // --- 1. LOAD USER DATA ---
  void _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String savedId = prefs.getString('user_id') ?? '';
      String savedName = prefs.getString('user_name') ?? '';

      if (savedId.isNotEmpty) {
        userId.value = savedId;
        userName.value = savedName;
      } else {
        if (Get.isRegistered<ProfileController>()) {
          final profile = Get.find<ProfileController>().userProfile;
          userName.value = profile['name'] ?? "Pelanggan";
          userId.value = profile['id'] ?? "";
        } else {
          Get.put(ProfileController());
          final profile = Get.find<ProfileController>().userProfile;
          userName.value = profile['name'] ?? "Pelanggan";
        }
      }
    } catch (e) {
      print("Error load user: $e");
      userName.value = "Pelanggan";
    }
  }

  // --- 2. LOAD DATA PESANAN ---
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

        // Simpan gambar ke variabel lokal controller (hanya untuk UI)
        _localImageBase64 = data['image_base64'];

        // Update UI agar gambar muncul di halaman Checkout ini
        orderData['image_base64'] = _localImageBase64;
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

  // --- 3. LOGIKA PROMO ---
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
        isPromoApplied.value = true;
        Get.snackbar(
          "Berhasil",
          "Potongan Rp ${formatRupiah(promoAmount)} diterapkan!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar("Gagal", "Voucher valid tapi nominal 0");
      }
    } else if (inputCode == 'HEMAT') {
      discount.value = 5000.0;
      isPromoApplied.value = true;
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

  void removePromo() {
    promoController.clear();
    discount.value = 0.0;
    isPromoApplied.value = false;
    calculateTotal();
    Get.snackbar(
      "Info",
      "Penggunaan voucher dibatalkan",
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // --- 4. HITUNG TOTAL ---
  void calculateTotal() {
    subTotal.value = itemPrice.value * quantity.value;
    double total = subTotal.value - discount.value;
    grandTotal.value = total < 0 ? 0 : total;
  }

  // --- 5. PROSES CHECKOUT (API CALL) ---
  Future<void> processCheckout() async {
    if (grandTotal.value <= 0 && discount.value == 0 && itemPrice.value > 0)
      return;

    isLoading.value = true;

    try {
      // 1. Siapkan Item untuk dikirim ke API
      // [PERUBAHAN]: image_base64 TIDAK dimasukkan ke sini agar payload ringan
      List<Map<String, dynamic>> itemsToSend = [
        {
          'id': orderData['id'],
          'product_id': orderData['id'],
          'product_name': orderData['name'],
          'qty': quantity.value,
          'price': itemPrice.value,
        },
      ];

      // 2. Panggil API Checkout
      final response = await _apiService.checkout(
        customerId: userId.value,
        items: itemsToSend,
        voucherCode: isPromoApplied.value ? promoController.text : null,
        paymentMethod: selectedPaymentMethod.value,
        tableNumber: lokasiPemesananController.text,
        discount: discount.value,
      );

      // 3. Handle Response
      if (response['status'] == 'success') {
        String orderId = response['data']['order_id'] ?? 'TRX-UNKNOWN';

        // [PENTING] Data untuk halaman Payment (Receipt)
        // Kita MASUKKAN LAGI image_base64 dari variabel lokal (_localImageBase64)
        // agar di halaman Payment gambar tetap muncul tanpa perlu download ulang.
        Map<String, dynamic> transactionDisplayData = {
          'order_id': orderId,
          'table_number': lokasiPemesananController.text,
          'payment_method': selectedPaymentMethod.value,
          'items': [
            {
              ...itemsToSend[0],
              'image_base64':
                  _localImageBase64, // Pasang kembali gambar lokal di sini
            },
          ],
          'summary': {
            'sub_total': subTotal.value,
            'discount': discount.value,
            'grand_total': grandTotal.value,
          },
        };

        // Pindah ke Halaman Payment
        Get.offNamed(
          '/payment',
          arguments: {
            'grand_total': grandTotal.value,
            'order_id': orderId,
            'transaction_data': transactionDisplayData,
          },
        );
      } else {
        Get.snackbar(
          "Gagal Checkout",
          response['message'] ?? "Terjadi kesalahan server",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Checkout Error: $e");
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
