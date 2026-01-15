import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();

  // State
  var isLoading = true.obs;
  var userProfile = <String, dynamic>{}.obs;

  // STATISTIK DATA ASLI
  var voucherCount = 0.obs; // Jumlah Voucher
  var userPoints = 0.obs; // Jumlah Poin

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading(true);
    // ... logika load profile dari SharedPreferences (kode lama) ...
    // Anggap user sudah login, kita panggil refreshProfile untuk ambil data terbaru
    await refreshProfile();
    isLoading(false);
  }

  Future<void> refreshProfile() async {
    try {
      // 1. Ambil Profile Terbaru (Jika ada endpoint profile)
      // ... (logika update profile user) ...

      // 2. AMBIL DATA VOUCHER (Hitung Jumlahnya)
      var vouchers = await _apiService.getVouchers();
      voucherCount.value = vouchers.length;

      // 3. AMBIL POIN USER (Opsional, jika ingin data poin asli juga)
      // Kita butuh ID user untuk cek poin. Jika di SharedPreferences ada ID, pakai itu.
      // Misal: String uid = userProfile['id'];
      // int points = await _apiService.getUserPoints(uid);
      // userPoints.value = points;
    } catch (e) {
      print("Error refresh profile: $e");
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed('/login');
  }
}
