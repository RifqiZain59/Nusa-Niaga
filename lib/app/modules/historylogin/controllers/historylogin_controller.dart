import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryloginController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var historyItems = <DocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLoginHistory();
  }

  Future<void> fetchLoginHistory() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? '';

      if (userId.isEmpty || userId == '0') {
        historyItems.clear();
        return;
      }

      // 1. Ambil data berdasarkan customer_id
      QuerySnapshot snapshot = await _firestore
          .collection('login_history')
          .where('customer_id', isEqualTo: userId)
          .get();

      // 2. Sorting Manual (Terbaru di atas) untuk menghindari error Index
      var sortedDocs = snapshot.docs.toList();
      sortedDocs.sort((a, b) {
        try {
          var dataA = a.data() as Map<String, dynamic>;
          var dataB = b.data() as Map<String, dynamic>;

          Timestamp timeA = dataA['login_time'] is Timestamp
              ? dataA['login_time']
              : Timestamp(0, 0);
          Timestamp timeB = dataB['login_time'] is Timestamp
              ? dataB['login_time']
              : Timestamp(0, 0);

          return timeB.compareTo(timeA); // Descending
        } catch (e) {
          return 0;
        }
      });

      historyItems.assignAll(sortedDocs);
    } catch (e) {
      print("Error fetch history: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
