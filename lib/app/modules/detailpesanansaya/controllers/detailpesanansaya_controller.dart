import 'package:get/get.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class DetailpesanansayaController extends GetxController {
  final ApiService apiService = ApiService();

  // Variabel untuk menyimpan data transaksi (Reactive)
  var transaction = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil data otomatis saat controller dibuat pertama kali
    if (Get.arguments != null) {
      setTransactionData(Get.arguments);
    }
  }

  // === FUNGSI YANG HILANG (SOLUSI ERROR ANDA) ===
  void setTransactionData(dynamic arguments) {
    if (arguments != null) {
      // Pastikan formatnya Map<String, dynamic> agar tidak error parsing
      try {
        transaction.value = Map<String, dynamic>.from(arguments);
      } catch (e) {
        print("Error parsing arguments: $e");
      }
    }
  }

  // Helper untuk mengambil URL gambar produk dari ApiService
  String getProductImageUrl(String? productId) {
    if (productId == null || productId.isEmpty) return "";
    return apiService.getProductImageUrl(productId);
  }
}
