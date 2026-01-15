import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = true.obs;
  var userProfile = <String, dynamic>{}.obs;

  // STATISTIK
  var voucherCount = 0.obs;
  var userPoints = 0.obs;
  var totalTransactions = 0.obs;

  // VARIABLE BARU UNTUK REFRESH GAMBAR
  var imageSignature = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      String id = prefs.getString('user_id') ?? '';
      String name = prefs.getString('user_name') ?? 'Pengguna';
      String email = prefs.getString('user_email') ?? '-';
      String role = prefs.getString('user_role') ?? 'Member';

      userProfile.value = {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      };

      // UPDATE SIGNATURE AGAR GAMBAR BERUBAH
      imageSignature.value = DateTime.now().millisecondsSinceEpoch;

      if (id.isNotEmpty) {
        await refreshLiveData(id, name);
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshLiveData(String userId, String userName) async {
    try {
      var vouchers = await _apiService.getVouchers();
      voucherCount.value = vouchers.length;

      int points = await _apiService.getUserPoints(userId);
      userPoints.value = points;

      var transactions = await _apiService.getTransactionHistory(userName);
      totalTransactions.value = transactions.length;
    } catch (e) {
      print("Error refreshing data: $e");
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed('/login');
  }
}
