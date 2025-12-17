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

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      product.assignAll(Get.arguments as Map<String, dynamic>);
      _initializePrice();
      isFavorite.value = product['is_favorite'] == true;
      isLoading.value = false;
    }
    fetchDetailProduct(); // Sinkronisasi ulang dengan database
    ever(quantity, (_) => _updateTotalPrice());
  }

  void _initializePrice() {
    double price = double.tryParse(product['price'].toString()) ?? 0.0;
    totalPrice.value = price * quantity.value;
  }

  // Logika Favorit: Agar status tidak hilang saat aplikasi ditutup/keluar
  Future<void> toggleFavorite() async {
    if (product['id'] == null || isFavoriteLoading.value) return;

    try {
      isFavoriteLoading(true);
      const int customerId = 1; // Sesuaikan dengan user yang sedang login

      final result = await _apiService.toggleFavorite(
        customerId,
        product['id'],
      );

      if (result['status'] != 'error') {
        isFavorite.value = !isFavorite.value;
        product['is_favorite'] = isFavorite.value;
        Get.snackbar(
          "Sukses",
          isFavorite.value ? "Ditambahkan ke favorit" : "Dihapus dari favorit",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint("Error Toggle Favorite: $e");
    } finally {
      isFavoriteLoading(false);
    }
  }

  Future<void> fetchDetailProduct() async {
    if (product['id'] == null) return;
    try {
      isLoading(true);
      // Memanggil API detail untuk mendapatkan status Like terbaru
      var detail = await _apiService.getProductDetail(product['id']);
      if (detail != null && detail['status'] != 'error') {
        product.addAll(detail);
        if (detail.containsKey('is_favorite')) {
          isFavorite.value = detail['is_favorite'] == true;
        }
        _updateTotalPrice();
      }
    } catch (e) {
      debugPrint("Error detail: $e");
    } finally {
      isLoading(false);
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
