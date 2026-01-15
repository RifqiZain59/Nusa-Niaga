import 'package:get/get.dart';
import 'package:nusaniaga/app/data/api_service.dart';
import '../../Profile/controllers/profile_controller.dart';

class PesanansayaController extends GetxController {
  final ApiService apiService = ApiService(); // Public agar bisa diakses View

  var isLoading = true.obs;
  var allTransactions = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading(true);

      // Ambil nama user
      String userName = "Guest";
      if (Get.isRegistered<ProfileController>()) {
        userName = Get.find<ProfileController>().userProfile['name'] ?? "Guest";
      }

      var data = await apiService.getTransactionHistory(userName);

      // Urutkan dari yang terbaru
      data.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(2000);
        DateTime dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      allTransactions.assignAll(data);
    } catch (e) {
      print("Error fetch history: $e");
    } finally {
      isLoading(false);
    }
  }
}
