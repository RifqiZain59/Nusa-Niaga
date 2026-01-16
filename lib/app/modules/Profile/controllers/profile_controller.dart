import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = true.obs;
  // Menampung data user: id, name, email, role, avatar, phone
  var userProfile = <String, dynamic>{}.obs;

  // STATISTIK
  var voucherCount = 0.obs;
  var userPoints = 0.obs;
  var totalTransactions = 0.obs;

  // VARIABLE UNTUK REFRESH GAMBAR
  var imageSignature = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  // --- 1. LOAD DATA DARI MEMORI HP ---
  Future<void> loadProfile() async {
    try {
      isLoading(true);

      final prefs = await SharedPreferences.getInstance();
      String id = prefs.getString('user_id') ?? '';
      String name = prefs.getString('user_name') ?? 'Pengguna';
      String email = prefs.getString('user_email') ?? '-';
      String phone = prefs.getString('user_phone') ?? '-'; // Load No HP
      String role = prefs.getString('user_role') ?? 'Member';
      String avatar = prefs.getString('user_avatar') ?? '';

      userProfile.value = {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone, // Masukkan ke map
        'role': role,
        'avatar': avatar,
      };

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

  // --- 2. FUNGSI UPDATE GLOBAL ---
  Future<void> saveUserData({
    required String id,
    required String name,
    required String email,
    String? phone,
    String? role,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_id', id);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);

    if (phone != null) await prefs.setString('user_phone', phone);
    if (role != null) await prefs.setString('user_role', role);
    if (avatarUrl != null) await prefs.setString('user_avatar', avatarUrl);

    // Update Reactive Map
    userProfile['id'] = id;
    userProfile['name'] = name;
    userProfile['email'] = email;
    if (phone != null) userProfile['phone'] = phone;
    if (role != null) userProfile['role'] = role;
    if (avatarUrl != null) userProfile['avatar'] = avatarUrl;

    userProfile.refresh();
    imageSignature.value = DateTime.now().millisecondsSinceEpoch;
  }

  Future<void> refreshLiveData(String userId, String userName) async {
    try {
      var vouchers = await _apiService.getVouchers();
      voucherCount.value = vouchers.length;

      int points = await _apiService.getUserPoints(userId);
      userPoints.value = points;

      var transactions = await _apiService.getTransactionHistory(userId);
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
    userProfile.clear();
    Get.offAllNamed('/login');
  }
}
