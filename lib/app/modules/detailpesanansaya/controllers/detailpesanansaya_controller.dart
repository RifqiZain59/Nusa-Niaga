import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api_service.dart';

class DetailpesanansayaController extends GetxController {
  final ApiService _apiService = ApiService();

  // Data Transaksi
  var transaction = <String, dynamic>{}.obs;

  // Form Review
  final TextEditingController reviewController = TextEditingController();
  var selectedRating = 0.obs;

  // Loading & State
  var isSubmitting = false.obs;

  // [PENTING] Set ID Produk yang tombol ulasannya harus hilang
  var reviewedProductIds = <String>{}.obs;

  // --- LOGIKA UTAMA: CEK STATUS REVIEW DARI SERVER ---
  void setTransactionData(Map<String, dynamic> data) {
    transaction.assignAll(data);

    // Reset list lokal
    reviewedProductIds.clear();

    // Cek setiap item, apakah backend bilang 'has_reviewed' == true?
    if (data['items'] != null && data['items'] is List) {
      for (var item in data['items']) {
        String pid = (item['product_id'] ?? item['id'] ?? '').toString();

        // Jika Backend bilang true, atau kita cek manual
        if (item['has_reviewed'] == true) {
          reviewedProductIds.add(pid);
        }
      }
    }
  }

  void resetReviewForm() {
    selectedRating.value = 0;
    reviewController.clear();
    isSubmitting.value = false;
  }

  Future<void> submitReview(String productId, int qty) async {
    int rating = selectedRating.value;
    String comment = reviewController.text.trim();

    if (rating == 0) {
      Get.snackbar(
        "Peringatan",
        "Mohon pilih jumlah bintang.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? '';

      if (userId.isEmpty) {
        isSubmitting.value = false;
        Get.snackbar("Error", "User ID tidak ditemukan.");
        return;
      }

      bool success = await _apiService.addReview(
        userId,
        productId,
        rating,
        comment: comment,
        qty: qty,
      );

      isSubmitting.value = false;

      if (success) {
        // [PENTING] Tambahkan ke list agar tombol langsung hilang tanpa refresh
        reviewedProductIds.add(productId);

        Get.back(); // Tutup Dialog
        Get.snackbar(
          "Sukses",
          "Ulasan berhasil dikirim!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar("Gagal", "Gagal mengirim ulasan.");
      }
    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
