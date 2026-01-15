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

  // ID Customer (Sementara dummy, nanti dari session)
  final String _customerId = "dummy_user_id";

  @override
  void onInit() {
    super.onInit();
    // 1. Ambil data dari halaman sebelumnya (Home)
    if (Get.arguments != null) {
      product.assignAll(Get.arguments as Map<String, dynamic>);
      _initializeData();
    }

    // 2. Refresh data detail dari server (untuk stok/deskripsi terbaru)
    fetchDetailProduct();

    // Listener perubahan quantity
    ever(quantity, (_) => _updateTotalPrice());
  }

  void _initializeData() {
    // Setup Harga Awal
    _updateTotalPrice();

    // Setup Status Favorit Awal
    if (product['is_favorite'] == true) {
      isFavorite.value = true;
    }

    // Stop loading karena data awal sudah ada
    isLoading.value = false;
  }

  Future<void> fetchDetailProduct() async {
    if (product['id'] == null) return;
    String productId = product['id'].toString();

    try {
      // Parallel Request: Detail Produk & Cek Favorit
      var results = await Future.wait([
        _apiService.getProductDetail(productId, customerId: _customerId),
        _apiService.getFavorites(_customerId),
      ]);

      var detailData = results[0];
      var favoriteData = results[1];

      // A. Update Data Produk (Merge dengan data lama)
      if (detailData != null && detailData is Map<String, dynamic>) {
        // Normalisasi Data API agar cocok dengan UI
        // API mungkin kirim 'category', Home kirim 'type'. Kita set keduanya.
        if (detailData['category'] != null) {
          detailData['type'] = detailData['category'];
        }

        product.addAll(detailData);
        _updateTotalPrice(); // Hitung ulang jika harga berubah dari server
      }

      // B. Update Status Favorit Real-time
      bool foundInFavorites = false;
      if (favoriteData is List) {
        foundInFavorites = favoriteData.any(
          (item) => item['product_id'].toString() == productId,
        );
      }

      isFavorite.value = foundInFavorites;
      product['is_favorite'] = foundInFavorites;
    } catch (e) {
      debugPrint("Error detail/favorite: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleFavorite() async {
    if (product['id'] == null || isFavoriteLoading.value) return;

    try {
      isFavoriteLoading(true);
      // Optimistic UI Update (Langsung berubah sebelum request selesai)
      isFavorite.value = !isFavorite.value;

      final result = await _apiService.toggleFavorite(
        _customerId,
        product['id'].toString(),
      );

      if (result['status'] == 'error') {
        // Revert jika gagal
        isFavorite.value = !isFavorite.value;
        Get.snackbar("Gagal", "Tidak dapat mengubah favorit");
      } else {
        // Sinkron data lokal
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
      isFavorite.value = !isFavorite.value; // Revert
      debugPrint("Error Toggle: $e");
    } finally {
      isFavoriteLoading(false);
    }
  }

  void incrementQuantity() => quantity.value++;

  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  void _updateTotalPrice() {
    // Parsing harga yang aman (bisa int, double, atau string)
    double price = 0.0;
    var pPrice = product['price'];

    if (pPrice is num) {
      price = pPrice.toDouble();
    } else if (pPrice is String) {
      // Hapus karakter non-angka (Rp, titik, dll)
      String clean = pPrice.replaceAll(RegExp(r'[^0-9]'), '');
      price = double.tryParse(clean) ?? 0.0;
    }

    totalPrice.value = price * quantity.value;
  }

  @override
  void onClose() {
    notesTextController.dispose();
    super.onClose();
  }
}
