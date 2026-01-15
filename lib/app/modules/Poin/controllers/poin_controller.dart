import 'package:get/get.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class PoinController extends GetxController {
  final ApiService _apiService = ApiService();

  var rewards = <dynamic>[].obs;
  var isLoading = true.obs;

  // Poin User
  var myPoints = 0.obs;

  // Dummy User ID (Harusnya dari session login)
  final String _userId = "dummy_user_id";

  @override
  void onInit() {
    super.onInit();
    fetchPoinData();
  }

  Future<void> fetchPoinData() async {
    try {
      isLoading(true);

      // Ambil data rewards dan poin user terbaru secara paralel
      var results = await Future.wait([
        _apiService.getRewards(),
        _apiService.getUserPoints(_userId),
      ]);

      var rewardList = results[0] as List<dynamic>;
      var points = results[1] as int;

      rewards.assignAll(rewardList);
      myPoints.value = points;
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data poin: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshData() async {
    await fetchPoinData();
  }
}
