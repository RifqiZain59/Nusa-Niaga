import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class DetailMenuController extends GetxController {
  final ApiService _apiService = ApiService();

  var product = <String, dynamic>{}.obs;
  var isLoading = true.obs;
  var isFavorite = false.obs;
  var isFavoriteLoading = false.obs;

  RxInt quantity = 1.obs;
  RxDouble totalPrice = 0.0.obs;
  final TextEditingController notesTextController = TextEditingController();

  // Hardcode ID Customer (Sesuaikan dengan Login Session nanti)
  final int _customerId = 1;

  @override
  void onInit() {
    super.onInit();
    // 1. Ambil data dari halaman sebelumnya (Home) agar UI langsung muncul
    if (Get.arguments != null) {
      product.assignAll(Get.arguments as Map<String, dynamic>);
      _initializePrice();

      // Set status awal dari kiriman halaman Home
      isFavorite.value = product['is_favorite'] == true;
      isLoading.value = false;
    }

    // 2. Refresh data dari server (Untuk harga terbaru & cek ulang status favorit)
    fetchDetailProduct();

    ever(quantity, (_) => _updateTotalPrice());
  }

  void _initializePrice() {
    double price = double.tryParse(product['price'].toString()) ?? 0.0;
    totalPrice.value = price * quantity.value;
  }

  // --- PERBAIKAN UTAMA DI SINI ---
  Future<void> fetchDetailProduct() async {
    if (product['id'] == null) return;
    try {
      // Jangan set isLoading(true) agar UI tidak berkedip (karena sudah ada data awal)

      // Kita jalankan 2 request sekaligus secara paralel:
      // 1. Detail Produk (untuk update harga/stok jika berubah)
      // 2. List Favorit User (untuk validasi apakah user benar2 me-like produk ini)
      var results = await Future.wait([
        _apiService.getProductDetail(product['id']),
        _apiService.getFavorites(_customerId),
      ]);

      var detailData = results[0];
      var favoriteData = results[1];

      // A. Update Data Produk
      if (detailData != null && detailData is Map<String, dynamic>) {
        // Gabungkan data baru ke data lama
        product.addAll(detailData);
        _updateTotalPrice();
      }

      // B. Update Status Favorit (Cek apakah ID produk ini ada di list favorit user)
      bool foundInFavorites = false;
      if (favoriteData is List) {
        // Mencari apakah product_id ini ada di dalam list yang dikembalikan server
        foundInFavorites = favoriteData.any(
          (item) => item['product_id'] == product['id'],
        );
      }

      // Update Observable UI
      isFavorite.value = foundInFavorites;

      // Sinkronkan ke variabel product agar konsisten
      product['is_favorite'] = foundInFavorites;
    } catch (e) {
      debugPrint("Error detail/favorite: $e");
    } finally {
      isLoading(false);
    }
  }

  // Logika Toggle Favorit
  Future<void> toggleFavorite() async {
    if (product['id'] == null || isFavoriteLoading.value) return;

    try {
      isFavoriteLoading(true);

      final result = await _apiService.toggleFavorite(
        _customerId,
        product['id'],
      );

      if (result['status'] != 'error') {
        // Balik status saat ini (True jadi False, False jadi True)
        isFavorite.value = !isFavorite.value;
        product['is_favorite'] = isFavorite.value;

        Get.snackbar(
          "Sukses",
          isFavorite.value ? "Ditambahkan ke favorit" : "Dihapus dari favorit",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      debugPrint("Error Toggle Favorite: $e");
      Get.snackbar("Error", "Gagal mengubah status favorit");
    } finally {
      isFavoriteLoading(false);
    }
  }

  void incrementQuantity() => quantity.value++;

  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  void _updateTotalPrice() {
    double price = double.tryParse(product['price'].toString()) ?? 0.0;
    totalPrice.value = price * quantity.value;
  }

  @override
  void onClose() {
    notesTextController.dispose();
    super.onClose();
  }
}
