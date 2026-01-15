import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();

  // State
  var isLoading = true.obs;

  // Menggunakan RxMap agar perubahan data terdeteksi otomatis
  var userProfile = <String, dynamic>{}.obs;

  // Statistik Data
  var voucherCount = 0.obs;
  var userPoints = 0.obs;
  var transactionCount = 0.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    _startAutoRefresh();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // --- FITUR AUTO REFRESH (AMAN DARI NULL) ---
  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Pengecekan Ketat: Hanya refresh jika ID ada dan valid
      if (userProfile.isNotEmpty &&
          userProfile['id'] != null &&
          userProfile['id'] != '' &&
          userProfile['id'] != 'Guest') {
        refreshProfile();
      }
    });
  }

  // --- LOAD DATA DARI HP (AMAN DARI NULL) ---
  Future<void> loadProfile() async {
    isLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();

      // TEKNIK ANTI NULL (??):
      // Jika data null, ganti dengan string kosong '' atau nilai default
      String uid = prefs.getString('user_id') ?? '';
      String name = prefs.getString('user_name') ?? 'Guest';
      String email = prefs.getString('user_email') ?? '-';
      String role = prefs.getString('user_role') ?? 'Member';
      String phone = prefs.getString('user_phone') ?? '-';

      // Simpan ke variable reactive
      userProfile.value = {
        'id': uid,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
      };

      // Hanya panggil API jika UID benar-benar ada
      if (uid.isNotEmpty && uid != 'Guest') {
        await refreshProfile();
      } else {
        print("Info: User belum login atau UID kosong. Skip API.");
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- AMBIL DATA DARI SERVER (AMAN DARI NULL) ---
  Future<void> refreshProfile() async {
    try {
      // 1. Pengecekan Ganda (Safety Check)
      // Jika userProfile kosong ATAU id-nya null ATAU id-nya kosong string
      if (userProfile.isEmpty ||
          userProfile['id'] == null ||
          userProfile['id'] == '') {
        return; // BERHENTI DISINI, JANGAN LANJUT (Supaya tidak error)
      }

      String uid = userProfile['id'];
      String name = userProfile['name'] ?? '';

      // 2. Ambil Voucher (Aman)
      try {
        var vouchers = await _apiService.getVouchers();
        if (voucherCount.value != vouchers.length) {
          voucherCount.value = vouchers.length;
        }
      } catch (_) {} // Abaikan error kecil

      // 3. Ambil Transaksi (Aman)
      if (name.isNotEmpty && name != 'Guest') {
        try {
          var transactions = await _apiService.getTransactionHistory(name);
          if (transactionCount.value != transactions.length) {
            transactionCount.value = transactions.length;
          }
        } catch (_) {}
      }

      // 4. AMBIL POIN (Aman)
      try {
        int points = await _apiService.getUserPoints(uid);
        if (userPoints.value != points) {
          userPoints.value = points;
          print("Poin terupdate: $points");
        }
      } catch (_) {}
    } catch (e) {
      print("Global Refresh Error: $e");
    }
  }

  void logout() async {
    _timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed('/login');
  }
}
