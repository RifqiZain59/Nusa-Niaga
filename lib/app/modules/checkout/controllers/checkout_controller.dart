import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // [WAJIB] Import ini
import 'package:nusaniaga/app/data/api_service.dart';

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

  // Simpan base64 gambar lokal untuk UI
  String? _localImageBase64;

  @override
  void onInit() {
    super.onInit();

    // Listener untuk validasi tombol lanjut
    lokasiPemesananController.addListener(_validateForm);
    promoController.addListener(() {
      isPromoFilled.value = promoController.text.isNotEmpty;
    });

    // 1. Load Data User dari Shared Preferences
    _loadUserData();

    // 2. Load Data Pesanan (Arguments)
    _loadInitialOrderData();

    // 3. Load Voucher
    _fetchVouchersFromApi();
  }

  void changePaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  // --- 1. LOAD USER DATA (SHARED PREFERENCES) ---
  void _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Ambil data user_id dan user_name yang disimpan saat Login
      String savedId = prefs.getString('user_id') ?? '';
      String savedName = prefs.getString('user_name') ?? 'Pelanggan';

      if (savedId.isNotEmpty) {
        userId.value = savedId;
        userName.value = savedName;
      } else {
        print("Warning: Data user tidak ditemukan di SharedPreferences");
        userName.value = "Pelanggan (Guest)";
      }
    } catch (e) {
      print("Error loading SharedPreferences: $e");
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

      // Jika ada ID produk, ambil detail tambahan (termasuk gambar base64 jika ada di Firestore)
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

        // Ambil gambar base64 jika ada untuk ditampilkan di Checkout
        _localImageBase64 = data['image_base64'];
        if (_localImageBase64 != null) {
          orderData['image_base64'] = _localImageBase64;
        }
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
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar("Gagal", "Voucher valid tapi nominal 0");
      }
    } else {
      Get.snackbar(
        "Gagal",
        "Kode voucher tidak valid",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
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
      snackPosition: SnackPosition.TOP,
    );
  }

  // --- 4. HITUNG TOTAL ---
  void calculateTotal() {
    subTotal.value = itemPrice.value * quantity.value;
    double total = subTotal.value - discount.value;
    grandTotal.value = total < 0 ? 0 : total;
  }

  // --- 5. PROSES CHECKOUT ---
  Future<void> processCheckout() async {
    if (grandTotal.value <= 0 && discount.value == 0 && itemPrice.value > 0)
      return;

    // Validasi User ID
    if (userId.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Data pengguna tidak ditemukan. Silakan login ulang.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Data item untuk dikirim ke API
      List<Map<String, dynamic>> itemsToSend = [
        {
          'id': orderData['id'],
          'product_id': orderData['id'],
          'product_name': orderData['name'],
          'qty': quantity.value,
          'price': itemPrice.value,
        },
      ];

      // Panggil API Checkout
      final response = await _apiService.checkout(
        customerId: userId.value, // Menggunakan ID dari SharedPreferences
        items: itemsToSend,
        voucherCode: isPromoApplied.value ? promoController.text : null,
        paymentMethod: selectedPaymentMethod.value,
        tableNumber: lokasiPemesananController.text,
        discount: discount.value,
      );

      if (response['status'] == 'success') {
        String orderId = response['data']['order_id'] ?? 'TRX-UNKNOWN';

        // Data untuk halaman Payment (Receipt)
        Map<String, dynamic> transactionDisplayData = {
          'order_id': orderId,
          'table_number': lokasiPemesananController.text,
          'payment_method': selectedPaymentMethod.value,
          'items': [
            {
              ...itemsToSend[0],
              'image_base64':
                  _localImageBase64, // Pasang gambar lokal agar muncul di struk
            },
          ],
          'summary': {
            'sub_total': subTotal.value,
            'discount': discount.value,
            'grand_total': grandTotal.value,
          },
        };

        // Redirect ke Payment View
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
