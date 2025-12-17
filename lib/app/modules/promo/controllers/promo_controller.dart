import 'package:get/get.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class PromoController extends GetxController {
  // Inisialisasi ApiService
  final ApiService _apiService = ApiService();

  // State untuk menampung data voucher asli dari database
  var vouchers = <dynamic>[].obs;

  // State untuk indikator loading
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Memanggil data voucher segera setelah controller diinisialisasi
    fetchVouchers();
  }

  /// Fungsi untuk mengambil data asli dari API
  Future<void> fetchVouchers() async {
    try {
      isLoading(true);
      // Memanggil fungsi getVouchers dari ApiService
      var fetchedData = await _apiService.getVouchers();

      // Mengisi list vouchers dengan data asli
      vouchers.assignAll(fetchedData);
    } catch (e) {
      // Menampilkan pesan error jika koneksi gagal
      Get.snackbar(
        'Error',
        'Gagal mengambil data voucher: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // Menghentikan loading setelah proses selesai (berhasil/gagal)
      isLoading(false);
    }
  }

  /// Fungsi untuk menarik data ulang (Pull to Refresh)
  Future<void> refreshData() async {
    await fetchVouchers();
  }
}
