import 'package:get/get.dart';
import 'package:nusaniaga/app/data/api_service.dart'; // Pastikan import ini benar

class DetailpesanansayaController extends GetxController {
  final ApiService _apiService = ApiService();

  // Data Transaksi
  var transaction = <String, dynamic>{}.obs;

  // Helper untuk Image URL
  String getProductImageUrl(String productId) {
    return _apiService.getProductImageUrl(productId);
  }

  @override
  void onInit() {
    super.onInit();
    // Tangkap data dari halaman sebelumnya
    if (Get.arguments != null && Get.arguments is Map) {
      transaction.assignAll(Get.arguments);
    }
  }
}
