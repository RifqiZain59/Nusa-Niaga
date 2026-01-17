import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ionicons/ionicons.dart';

import 'package:nusaniaga/app/modules/detail_menu/views/detail_menu_view.dart';
import 'package:nusaniaga/app/modules/detail_menu/controllers/detail_menu_controller.dart';

class WishlistController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var wishlistItems = <DocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  // --- 1. FETCH DATA TANPA INDEX (SORTING LOKAL) ---
  Future<void> fetchWishlist() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      String userIdString = prefs.getString('user_id') ?? '';

      if (userIdString.isEmpty || userIdString == '0') {
        wishlistItems.clear();
        return;
      }

      // --- QUERY 1: ID STRING (Tanpa orderBy) ---
      // Kita menghapus .orderBy('created_at') di sini agar tidak butuh Index
      QuerySnapshot snapshot = await _firestore
          .collection('favorites')
          .where('customer_id', isEqualTo: userIdString)
          .get();

      // --- QUERY 2: ID INTEGER (Fallback) ---
      if (snapshot.docs.isEmpty) {
        int? userIdInt = int.tryParse(userIdString);
        if (userIdInt != null) {
          snapshot = await _firestore
              .collection('favorites')
              .where('customer_id', isEqualTo: userIdInt)
              .get();
        }
      }

      // --- SORTING MANUAL DI DART (Client-Side) ---
      // Karena kita hapus orderBy di query, data mungkin acak.
      // Kita urutkan di sini berdasarkan 'created_at' (Descending/Terbaru)
      var sortedDocs = snapshot.docs.toList();

      sortedDocs.sort((a, b) {
        try {
          var dataA = a.data() as Map<String, dynamic>;
          var dataB = b.data() as Map<String, dynamic>;

          // Ambil timestamp, jika null anggap tanggal lama (0)
          Timestamp timeA = dataA['created_at'] is Timestamp
              ? dataA['created_at']
              : Timestamp(0, 0);
          Timestamp timeB = dataB['created_at'] is Timestamp
              ? dataB['created_at']
              : Timestamp(0, 0);

          // Bandingkan: B banding A agar Descending (Terbaru di atas)
          return timeB.compareTo(timeA);
        } catch (e) {
          return 0;
        }
      });

      // Masukkan hasil yang sudah diurutkan ke variabel state
      wishlistItems.assignAll(sortedDocs);
    } catch (e) {
      print("Error fetch wishlist: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- 2. HAPUS DARI FAVORIT ---
  Future<void> removeFromWishlist(String docId) async {
    try {
      await _firestore.collection('favorites').doc(docId).delete();
      wishlistItems.removeWhere((item) => item.id == docId);

      _showCenterPopup(
        title: "Dihapus",
        message: "Produk dihapus dari wishlist",
        icon: Ionicons.trash_bin,
        color: Colors.grey,
      );
    } catch (e) {
      _showCenterPopup(
        title: "Gagal",
        message: "Gagal menghapus data",
        icon: Ionicons.warning,
        color: Colors.red,
      );
    }
  }

  // --- 3. NAVIGASI KE DETAIL ---
  void goToDetail(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    Map<String, dynamic> arguments = {
      'id': data['product_id'],
      'name': data['product_name'],
      'image_url': data['image_url'],
      'price': data['price'],
      'category': data['category'],
      'is_favorite': true,
    };

    Get.to(
      () => DetailMenuView(),
      arguments: arguments,
      binding: BindingsBuilder(() {
        Get.put(DetailMenuController());
      }),
    )?.then((_) {
      fetchWishlist();
    });
  }

  // --- 4. POP-UP DIALOG ---
  void _showCenterPopup({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    if (Get.isDialogOpen == true) Get.back();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 50, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Get.isDialogOpen == true) Get.back();
    });
  }
}
