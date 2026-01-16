import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_service.dart';

class DetailMenuController extends GetxController {
  final ApiService _apiService = ApiService();

  // --- STATE VARIABLES ---
  var product = <String, dynamic>{}.obs;
  var isLoading = true.obs; // Loading awal (Spinner)
  var isReloading = false.obs; // Loading saat refresh (Blur)
  var isFavorite = false.obs;
  var isFavoriteLoading = false.obs;

  RxInt quantity = 1.obs;
  RxDouble totalPrice = 0.0.obs;

  // Controller untuk catatan (opsional, jika ingin ditambahkan di view nanti)
  final TextEditingController notesTextController = TextEditingController();

  // Dummy Customer ID (Ganti dengan ID asli dari SharedPref/GetStorage saat login)
  String get _customerId => "1";

  @override
  void onInit() {
    super.onInit();
    // 1. Ambil data argument dari halaman sebelumnya
    if (Get.arguments != null && Get.arguments is Map) {
      product.assignAll(Map<String, dynamic>.from(Get.arguments));
      _initializeData();
    }

    // 2. Fetch data terbaru dari server
    fetchDetailProduct();

    // 3. Listener perubahan quantity untuk update harga real-time
    ever(quantity, (_) => _updateTotalPrice());
  }

  void _initializeData() {
    _updateTotalPrice();

    // Set status favorit awal dari data argument
    if (product['is_favorite'] == true || product['is_favorite'] == 1) {
      isFavorite.value = true;
    } else {
      isFavorite.value = false;
    }

    // Jika data produk ada, matikan loading spinner awal
    if (product.isNotEmpty) isLoading.value = false;
  }

  // --- FUNGSI REFRESH (PULL TO REFRESH) ---
  Future<void> refreshData() async {
    isReloading.value = true; // Aktifkan BLUR di View

    // Panggil ulang API
    await fetchDetailProduct();

    // Delay tambahan agar animasi blur terlihat (UX)
    await Future.delayed(const Duration(milliseconds: 800));

    isReloading.value = false; // Matikan BLUR
  }

  // --- FETCH DATA DARI API ---
  Future<void> fetchDetailProduct() async {
    if (product['id'] == null) return;
    String productId = product['id'].toString();

    try {
      // Request Paralel: Detail Produk & Status Favorit
      var results = await Future.wait([
        _apiService.getProductDetail(productId, customerId: _customerId),
        _apiService.getFavorites(_customerId),
      ]);

      var detailData = results[0];
      var favoriteData = results[1];

      // Update Data Produk
      if (detailData != null && detailData is Map<String, dynamic>) {
        if (detailData['category'] != null) {
          detailData['type'] = detailData['category'];
        }
        product.addAll(detailData);
        _updateTotalPrice();
      }

      // Cek apakah produk ini ada di daftar favorit user
      bool foundInFavorites = false;
      if (favoriteData is List) {
        foundInFavorites = favoriteData.any(
          (item) => item['product_id'].toString() == productId,
        );
      }

      isFavorite.value = foundInFavorites;
      product['is_favorite'] = foundInFavorites;
    } catch (e) {
      debugPrint("Error fetching detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIKA FAVORIT (LENGKAP) ---
  Future<void> toggleFavorite() async {
    if (product['id'] == null || isFavoriteLoading.value) return;

    try {
      isFavoriteLoading.value = true;
      isFavorite.value =
          !isFavorite.value; // Optimistic Update (Ubah UI duluan)

      final result = await _apiService.toggleFavorite(
        _customerId,
        product['id'].toString(),
      );

      if (result['status'] == 'error') {
        // Jika gagal, kembalikan status ke semula
        isFavorite.value = !isFavorite.value;
        Get.snackbar("Gagal", "Gagal menyimpan favorit");
      } else {
        // Jika sukses, update data produk lokal
        product['is_favorite'] = isFavorite.value;

        Get.snackbar(
          "Sukses",
          isFavorite.value ? "Disimpan ke favorit" : "Dihapus dari favorit",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          margin: const EdgeInsets.all(20),
          borderRadius: 10,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      isFavorite.value = !isFavorite.value; // Revert jika error exception
      Get.snackbar("Error", "Gagal menghubungi server");
    } finally {
      isFavoriteLoading.value = false;
    }
  }

  // --- LOGIKA QUANTITY ---
  void incrementQuantity() => quantity.value++;

  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  // --- LOGIKA HARGA ---
  void _updateTotalPrice() {
    double price = 0.0;
    var pPrice = product['price'];

    if (pPrice != null) {
      if (pPrice is num) {
        price = pPrice.toDouble();
      } else if (pPrice is String) {
        // Membersihkan string harga (misal: "Rp 15.000" -> "15000")
        String clean = pPrice.replaceAll(RegExp(r'[^0-9]'), '');
        price = double.tryParse(clean) ?? 0.0;
      }
    }

    totalPrice.value = price * quantity.value;
  }

  @override
  void onClose() {
    notesTextController.dispose(); // Bersihkan controller teks
    super.onClose();
  }
}
