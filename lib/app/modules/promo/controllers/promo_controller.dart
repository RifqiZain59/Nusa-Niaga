import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PromoController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State
  var isLoading = true.obs;
  var vouchers = <DocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPromos();
  }

  // Fungsi yang dipanggil saat tarik layat (Pull to Refresh)
  Future<void> refreshData() async {
    // Kita tidak set isLoading = true disini agar UI tidak 'flicker' jadi skeleton
    // cukup biarkan spinner refresh indicator yang berputar
    await fetchPromos(isRefresh: true);
  }

  Future<void> fetchPromos({bool isRefresh = false}) async {
    try {
      // Hanya tampilkan skeleton loading jika ini bukan refresh (awal buka)
      if (!isRefresh) {
        isLoading.value = true;
      }

      // Ambil data dari collection 'vouchers'
      QuerySnapshot snapshot = await _firestore
          .collection('vouchers')
          .where('is_active', isEqualTo: true)
          .get();

      // Update data
      vouchers.assignAll(snapshot.docs);
    } catch (e) {
      print("Error fetch vouchers: $e");
    } finally {
      // Matikan loading
      isLoading.value = false;
    }
  }
}
