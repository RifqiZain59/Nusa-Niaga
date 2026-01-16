import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class PesanansayaController extends GetxController {
  final ApiService apiService = ApiService();
  final GetStorage _box = GetStorage();

  var allTransactions = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;

    // Ambil User ID dari Storage
    var userData = _box.read('user_data');
    String userId = userData?['id']?.toString() ?? '';

    if (userId.isNotEmpty) {
      try {
        // Panggil API Transaction History
        // Pastikan 'getTransactionHistory' ada di api_service.dart
        var data = await apiService.getTransactionHistory(userId);
        allTransactions.assignAll(data);
      } catch (e) {
        print("Error fetch history: $e");
      }
    } else {
      print("User ID kosong / Belum Login");
    }

    isLoading.value = false;
  }
}
