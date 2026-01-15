import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan Firebase Auth
import '../../../data/api_service.dart';
import '../../login/views/login_view.dart'; // Sesuaikan path ke LoginView

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State untuk data user dan status loading
  var userProfile = <String, dynamic>{}.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    isLoading.value = true;
    try {
      // AMBIL DATA DARI FIREBASE AUTH SEBAGAI DATA DASAR
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Set data awal dari Firebase (jika API gagal, setidaknya ini muncul)
        userProfile.value = {
          'name': currentUser.displayName ?? "User",
          'email': currentUser.email ?? "",
          'role': 'Member', // Default role
        };

        // OPSIONAL: AMBIL DATA LENGKAP DARI API SERVICE KAMU
        // Jika kamu menyimpan data tambahan (alamat, no hp) di database sendiri
        // var response = await _apiService.getProfileByEmail(currentUser.email!);
        // if (response['status'] == 'success') {
        //    userProfile.value = response['data'];
        // }
      } else {
        // Tidak ada user login
        userProfile.value = {};
      }
    } catch (e) {
      print("Error fetch profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Helper untuk refresh data (pull-to-refresh)
  Future<void> refreshProfile() async {
    fetchUserProfile();
  }

  // Fungsi Logout
  Future<void> logout() async {
    try {
      // 1. Logout dari Firebase
      await _auth.signOut();

      // 2. Kembali ke Halaman Login & Hapus semua history page sebelumnya
      Get.offAll(() => const LoginView());
    } catch (e) {
      Get.snackbar("Error", "Gagal keluar: $e");
    }
  }
}
