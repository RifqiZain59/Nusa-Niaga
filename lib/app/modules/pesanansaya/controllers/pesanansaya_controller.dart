import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class PesanansayaController extends GetxController {
  final ApiService apiService = ApiService();

  var allTransactions = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? '';

      if (userId.isNotEmpty) {
        // Pastikan API Service mengembalikan list data sesuai struktur database baru
        var data = await apiService.getTransactionHistory(userId);

        if (data.isNotEmpty) {
          // Urutkan dari yang terbaru (opsional, jika ada created_at)
          // data.sort((a, b) => b['created_at'].compareTo(a['created_at']));
          allTransactions.assignAll(data);
        } else {
          allTransactions.clear();
        }
      } else {
        allTransactions.clear();
      }
    } catch (e) {
      print("Error fetch history: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
