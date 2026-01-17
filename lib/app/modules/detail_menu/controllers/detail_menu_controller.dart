import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // [WAJIB] Pakai ini
import 'package:ionicons/ionicons.dart';
import '../../../data/api_service.dart';

class DetailMenuController extends GetxController {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- STATE VARIABLES ---
  var product = <String, dynamic>{}.obs;
  var isLoading = true.obs;
  var isReloading = false.obs;

  // Status Favorit
  var isFavorite = false.obs;
  var isFavoriteLoading = false.obs;

  // Transaksi
  RxInt quantity = 1.obs;
  RxDouble totalPrice = 0.0.obs;

  final TextEditingController notesTextController = TextEditingController();

  // Variabel lokal untuk data user
  String _currentUserId = '';
  String _currentUserName = '';

  @override
  void onInit() {
    super.onInit();

    // 1. Ambil argumen dari halaman sebelumnya (Home/Wishlist)
    if (Get.arguments != null && Get.arguments is Map) {
      product.assignAll(Map<String, dynamic>.from(Get.arguments));
      _initializeData();
    }

    // 2. Load Data User & Produk
    _loadData();

    // 3. Listener perubahan jumlah
    ever(quantity, (_) => _updateTotalPrice());
  }

  void _initializeData() {
    _updateTotalPrice();
    // Jika data dari home sudah ada status favorit, pakai dulu sementara
    if (product['is_favorite'] == true) {
      isFavorite.value = true;
    }
    if (product.isNotEmpty) isLoading.value = false;
  }

  Future<void> refreshData() async {
    isReloading.value = true;
    await _loadData();
    await Future.delayed(const Duration(milliseconds: 800));
    isReloading.value = false;
  }

  // --- LOAD DATA (USER + PRODUK) ---
  Future<void> _loadData() async {
    if (product['id'] == null) return;
    String productId = product['id'].toString();

    try {
      // A. Ambil User ID dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id') ?? '';
      _currentUserName = prefs.getString('user_name') ?? 'Pengguna';

      // B. Request API & Cek Firestore secara Paralel
      var results = await Future.wait([
        _apiService.getProductDetail(productId, customerId: _currentUserId),
        _checkFavoriteStatusFirestore(productId),
      ]);

      var detailData = results[0] as Map<String, dynamic>?;
      var isFavFirestore = results[1] as bool;

      // C. Update Data Produk dengan detail terbaru
      if (detailData != null && detailData['status'] != 'error') {
        if (detailData['category'] != null) {
          detailData['type'] = detailData['category'];
        }
        product.addAll(detailData);
        _updateTotalPrice();
      }

      // D. Sinkronisasi Status Favorit
      isFavorite.value = isFavFirestore;
      product['is_favorite'] = isFavFirestore;
    } catch (e) {
      debugPrint("Error fetching detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Cek apakah dokumen ada di Firestore
  Future<bool> _checkFavoriteStatusFirestore(String productId) async {
    if (_currentUserId.isEmpty || _currentUserId == '0') return false;
    try {
      String docId = "${_currentUserId}_$productId";
      final doc = await _firestore.collection('favorites').doc(docId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // --- LOGIKA FAVORIT (SIMPAN KE FIRESTORE) ---
  Future<void> toggleFavorite() async {
    if (product['id'] == null || isFavoriteLoading.value) return;

    // 1. Cek Login
    if (_currentUserId.isEmpty || _currentUserId == '0') {
      _showCenterPopup(
        title: "Akses Ditolak",
        message: "Silakan login terlebih dahulu",
        icon: Ionicons.alert_circle,
        color: Colors.red,
      );
      return;
    }

    String productId = product['id'].toString();
    isFavoriteLoading.value = true;

    // 2. Optimistic UI Update (Ubah icon duluan biar responsif)
    bool previousState = isFavorite.value;
    isFavorite.value = !previousState;

    try {
      // Buat ID Dokumen Unik (User_Produk)
      String docId = "${_currentUserId}_$productId";
      final docRef = _firestore.collection('favorites').doc(docId);

      if (isFavorite.value) {
        // --- SIMPAN (ADD) ---
        await docRef.set({
          'customer_id': _currentUserId,
          'customer_name': _currentUserName, // Nama user tersimpan di sini
          'product_id': productId,
          'product_name': product['name'] ?? 'Unknown Product',
          'image_url': product['image_url'] ?? product['image'] ?? '',
          'price': product['price'] ?? 0,
          'category': product['category'] ?? product['type'] ?? 'Menu',
          'created_at': FieldValue.serverTimestamp(),
        });

        _showCenterPopup(
          title: "Tersimpan",
          message: "Berhasil masuk daftar favorit",
          icon: Ionicons.heart,
          color: Colors.pink,
        );
      } else {
        // --- HAPUS (REMOVE) ---
        await docRef.delete();

        _showCenterPopup(
          title: "Dihapus",
          message: "Dihapus dari daftar favorit",
          icon: Ionicons.trash_bin,
          color: Colors.grey,
        );
      }

      // Update state produk lokal
      product['is_favorite'] = isFavorite.value;
    } catch (e) {
      // Revert jika gagal koneksi
      isFavorite.value = previousState;
      _showCenterPopup(
        title: "Gagal",
        message: "Gagal menyimpan data",
        icon: Ionicons.warning,
        color: Colors.red,
      );
      debugPrint("Error Fav: $e");
    } finally {
      isFavoriteLoading.value = false;
    }
  }

  // --- HELPER POP-UP MENGAMBANG (DIALOG) ---
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

    // Auto close 1.5 detik
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Get.isDialogOpen == true) Get.back();
    });
  }

  // --- LOGIKA HITUNG HARGA ---
  void incrementQuantity() => quantity.value++;
  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  void _updateTotalPrice() {
    double price = 0.0;
    var pPrice = product['price'];
    if (pPrice != null) {
      if (pPrice is num) {
        price = pPrice.toDouble();
      } else if (pPrice is String) {
        String clean = pPrice.replaceAll(RegExp(r'[^0-9]'), '');
        price = double.tryParse(clean) ?? 0.0;
      }
    }
    totalPrice.value = price * quantity.value;
  }

  @override
  void onClose() {
    notesTextController.dispose();
    super.onClose();
  }
}
