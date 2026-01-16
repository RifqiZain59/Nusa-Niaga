import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nusaniaga/app/modules/Scanner/views/scanner_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api_service.dart';

class PoinController extends GetxController {
  final ApiService _apiService = ApiService();

  // State Variables
  var redemptionHistory = <dynamic>[].obs; // List Riwayat
  var isLoading = true.obs;
  var myPoints = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  // --- 1. FETCH DATA (Poin & History) ---
  Future<void> refreshData() async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? '';

      if (userId.isEmpty) {
        isLoading(false);
        return;
      }

      // Ambil Poin & Riwayat secara Paralel (Tanpa Rewards)
      var results = await Future.wait([
        _apiService.getUserPoints(userId), // Index 0
        _apiService.getPointHistory(userId), // Index 1
      ]);

      // Update UI
      myPoints.value = results[0] as int;

      var histList = results[1];
      if (histList != null && histList is List) {
        redemptionHistory.assignAll(histList);
      } else {
        redemptionHistory.clear();
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- 2. FITUR SCAN QR CODE ---
  void scanQrCode() async {
    // Navigasi ke halaman ScannerView dan tunggu hasil scan
    final result = await Get.to(() => const ScannerView());

    // Jika ada hasil scan (String)
    if (result != null && result is String) {
      // Format QR dari Web Admin: "REDEEM|NamaUser|NamaItem|JumlahPoin"
      // Contoh: "REDEEM|Budi|Payung Lipat|20"

      List<String> parts = result.split('|');

      // Validasi Format QR
      if (parts.length >= 4 && parts[0] == 'REDEEM') {
        String itemName = parts[2];
        int pointsToDeduct = int.tryParse(parts[3]) ?? 0;

        // Lakukan eksekusi ke API
        _processRedemption(pointsToDeduct, itemName);
      } else {
        Get.snackbar(
          "Gagal",
          "Format QR Code tidak dikenali/salah.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // --- 3. PROSES PENUKARAN KE API ---
  void _processRedemption(int points, String item) async {
    // Tampilkan Loading Dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? '';

    // Panggil API redeem_via_scan
    final response = await _apiService.redeemViaScan(userId, points, item);

    Get.back(); // Tutup Loading Dialog

    if (response['status'] == 'success') {
      // Sukses
      Get.snackbar(
        "Berhasil!",
        "Tukar $points Poin untuk $item sukses.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      // Refresh data agar poin berkurang & riwayat muncul
      refreshData();
    } else {
      // Gagal (Misal poin kurang)
      Get.snackbar(
        "Gagal Penukaran",
        response['message'] ?? "Terjadi kesalahan",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
