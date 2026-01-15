import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  // === STATE VARIABLES ===
  var isLoading = true.obs;

  // Data Master (Database Lokal Sementara)
  var allProducts = <dynamic>[].obs;

  // Data Tampil (Hasil Filter)
  var filteredProducts = <dynamic>[].obs;

  var categoryList = <String>[].obs;
  var banners = <dynamic>[].obs;

  // Filter State
  var searchQuery = "".obs;
  var selectedCategory = "All".obs;
  var address = "Mencari lokasi...".obs;

  // Cache Internal untuk Favorit
  final Set<String> _favoriteIds = {};
  String _currentUserId = "";

  @override
  void onInit() {
    super.onInit();

    // 1. Jalankan fungsi awal
    fetchHomeData();
    determinePosition();

    // 2. Listener: Jika Search diketik, tunggu 500ms lalu filter
    debounce(
      searchQuery,
      (_) => _applyFilters(),
      time: const Duration(milliseconds: 500),
    );

    // 3. Listener: Jika Kategori berubah, langsung filter
    ever(selectedCategory, (_) => _applyFilters());
  }

  // === FUNGSI UTAMA: AMBIL DATA ===
  Future<void> fetchHomeData() async {
    try {
      isLoading(true);

      // A. Ambil User ID dari Login
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id') ?? '';

      // B. Request Data dari Server secara Paralel (Biar Cepat)
      var results = await Future.wait([
        _apiService.getBanners(),
        _apiService.getCategories(),
        _apiService.getProducts(),
        // Hanya ambil favorit jika user sudah login
        if (_currentUserId.isNotEmpty)
          _apiService.getFavorites(_currentUserId)
        else
          Future.value([]),
      ]);

      var fetchedBanners = results[0] as List<dynamic>;
      var fetchedCategories = results[1] as List<dynamic>;
      var fetchedProducts = results[2] as List<dynamic>;
      var favoriteData = results[3] as List<dynamic>;

      // C. Setup List Kategori
      List<String> tempCats = ["All"];
      for (var item in fetchedCategories) {
        // Pastikan key sesuai dengan response API ('name' atau 'category_name')
        tempCats.add(item['name'].toString());
      }
      categoryList.assignAll(tempCats);

      // D. Setup Cache Favorit
      _favoriteIds.clear();
      for (var fav in favoriteData) {
        _favoriteIds.add(fav['product_id'].toString());
      }

      // E. Gabungkan Data Produk dengan Status Favorit
      var processedProducts = _mapFavoritesToProducts(fetchedProducts);

      // F. Simpan ke State
      banners.assignAll(fetchedBanners);
      allProducts.assignAll(processedProducts);

      // G. Terapkan Filter Awal (Tampilkan Semua)
      _applyFilters();
    } catch (e) {
      print("Error Fetch Home: $e");
      // Jangan tampilkan snackbar error jika hanya masalah koneksi sesaat, cukup print
    } finally {
      isLoading(false);
    }
  }

  // === LOGIKA FILTER GABUNGAN ===
  void _applyFilters() {
    // Mulai dari semua produk
    List<dynamic> result = List.from(allProducts);

    // 1. Filter Kategori
    if (selectedCategory.value != "All") {
      result = result.where((p) {
        String cat = (p['category'] ?? '').toString();
        // Case insensitive comparison
        return cat.toLowerCase() == selectedCategory.value.toLowerCase();
      }).toList();
    }

    // 2. Filter Search
    if (searchQuery.value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase();
      result = result.where((p) {
        String name = (p['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }

    // Update Tampilan
    filteredProducts.assignAll(result);
  }

  // === HELPER: MAPPING FAVORIT ===
  List<dynamic> _mapFavoritesToProducts(List<dynamic> rawProducts) {
    return rawProducts.map((product) {
      // Clone map agar tidak mengubah referensi asli secara tidak sengaja
      var newMap = Map<String, dynamic>.from(product);
      String pid = newMap['id'].toString();

      // Cek apakah ID produk ada di daftar favorit user
      newMap['is_favorite'] = _favoriteIds.contains(pid);
      return newMap;
    }).toList();
  }

  // === AKSI USER ===

  // Ganti Kategori (Dipanggil dari View)
  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  // Toggle Favorit (Love)
  Future<void> toggleFavorite(String productId) async {
    if (_currentUserId.isEmpty) {
      Get.snackbar("Info", "Silakan login untuk menyimpan favorit");
      return;
    }

    // 1. Optimistic Update (Ubah UI duluan biar responsif)
    bool isCurrentlyFav = _favoriteIds.contains(productId);
    if (isCurrentlyFav) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }

    // 2. Refresh List Produk di UI
    // Kita update data master dan data filter agar checkbox berubah
    allProducts.value = _mapFavoritesToProducts(allProducts);
    _applyFilters();

    // 3. Kirim Request ke Server (Background)
    await _apiService.toggleFavorite(_currentUserId, productId);
  }

  // Refresh Pull-to-Refresh
  Future<void> refreshHomeData() async {
    await fetchHomeData();
    await determinePosition();
  }

  // === GEOLOCATION ===
  Future<void> determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        address.value = "GPS Mati";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          address.value = "Izin Lokasi Ditolak";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        address.value = "Izin Lokasi Permanen Ditolak";
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Format: Kecamatan, Kota (Contoh: "Kebayoran Baru, Jakarta Selatan")
        address.value = "${place.subLocality ?? ''}, ${place.locality ?? ''}";
      }
    } catch (e) {
      print("Lokasi Error: $e");
      address.value = "Indonesia";
    }
  }
}
