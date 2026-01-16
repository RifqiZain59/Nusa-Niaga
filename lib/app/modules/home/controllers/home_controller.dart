import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nusaniaga/app/data/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  // === STATE VARIABLES ===
  var isLoading = true.obs; // Loading Awal (Spinner)
  var isReloading = false.obs; // Loading Tarik Layar (Blur Box)

  // Data User
  var userName = "Pengguna".obs;
  var address = "Mencari lokasi...".obs;

  // Data Produk & Banner
  var allProducts = <dynamic>[].obs;
  var filteredProducts = <dynamic>[].obs;
  var categoryList = <String>[].obs;
  var banners = <dynamic>[].obs;

  // Filter State
  var searchQuery = "".obs;
  var selectedCategory = "All".obs;

  // Cache Favorit
  final Set<String> _favoriteIds = {};
  String _currentUserId = "";

  @override
  void onInit() {
    super.onInit();

    // 1. Load Data Awal
    fetchHomeData(isRefresh: false); // Mode awal (Spinner)
    determinePosition();

    // 2. Listener Pencarian
    debounce(
      searchQuery,
      (_) => _applyFilters(),
      time: const Duration(milliseconds: 500),
    );

    // 3. Listener Kategori
    ever(selectedCategory, (_) => _applyFilters());
  }

  // === FUNGSI UTAMA FETCH DATA ===
  // Parameter isRefresh menentukan jenis loading yang dipakai
  Future<void> fetchHomeData({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isReloading.value = true; // Aktifkan Blur
      } else {
        isLoading.value = true; // Aktifkan Spinner Awal
      }

      // A. Ambil Data User Lokal
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id') ?? '';

      // Update Nama User
      String savedName = prefs.getString('user_name') ?? 'Pengguna';
      List<String> names = savedName.split(' ');
      userName.value = names.isNotEmpty ? names[0] : savedName;

      // B. Request API Paralel
      var results = await Future.wait([
        _apiService.getBanners(),
        _apiService.getCategories(),
        _apiService.getProducts(),
        if (_currentUserId.isNotEmpty)
          _apiService.getFavorites(_currentUserId)
        else
          Future.value([]),
      ]);

      // Jika refresh, beri sedikit delay agar animasi blur terlihat smooth
      if (isRefresh) await Future.delayed(const Duration(milliseconds: 800));

      var fetchedBanners = results[0] as List<dynamic>;
      var fetchedCategories = results[1] as List<dynamic>;
      var fetchedProducts = results[2] as List<dynamic>;
      var favoriteData = results[3] as List<dynamic>;

      // C. Setup Kategori
      List<String> tempCats = ["All"];
      for (var item in fetchedCategories) {
        tempCats.add(item['name'].toString());
      }
      categoryList.assignAll(tempCats);

      // D. Setup Favorit
      _favoriteIds.clear();
      for (var fav in favoriteData) {
        var pid = fav['product_id'] ?? fav['id'];
        if (pid != null) _favoriteIds.add(pid.toString());
      }

      // E. Mapping Produk & Favorit
      var processedProducts = _mapFavoritesToProducts(fetchedProducts);

      // F. Simpan ke State
      banners.assignAll(fetchedBanners);
      allProducts.assignAll(processedProducts);

      // G. Terapkan Filter
      _applyFilters();
    } catch (e) {
      print("Error Fetch Home: $e");
    } finally {
      // Matikan Loading sesuai tipe
      if (isRefresh) {
        isReloading.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  // === FUNGSI KHUSUS PULL-TO-REFRESH ===
  // Dipanggil oleh RefreshIndicator di View
  Future<void> refreshHomeData() async {
    // Panggil fetchHomeData dengan mode refresh (Blur)
    await fetchHomeData(isRefresh: true);
    // Update lokasi juga saat refresh
    determinePosition();
  }

  // ... (Sisa fungsi tidak berubah) ...

  void _applyFilters() {
    List<dynamic> result = List.from(allProducts);

    if (selectedCategory.value != "All") {
      result = result.where((p) {
        String cat = (p['category'] ?? '').toString();
        return cat.toLowerCase() == selectedCategory.value.toLowerCase();
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase();
      result = result.where((p) {
        String name = (p['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }

    filteredProducts.assignAll(result);
  }

  List<dynamic> _mapFavoritesToProducts(List<dynamic> rawProducts) {
    return rawProducts.map((product) {
      var newMap = Map<String, dynamic>.from(product);
      String pid = newMap['id'].toString();
      newMap['is_favorite'] = _favoriteIds.contains(pid);
      return newMap;
    }).toList();
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  Future<void> toggleFavorite(String productId) async {
    if (_currentUserId.isEmpty) {
      Get.snackbar("Info", "Silakan login untuk menyimpan favorit");
      return;
    }

    bool isCurrentlyFav = _favoriteIds.contains(productId);
    if (isCurrentlyFav) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }

    // Update UI Lokal dulu (Optimistic)
    allProducts.value = _mapFavoritesToProducts(allProducts);
    _applyFilters();

    try {
      await _apiService.toggleFavorite(_currentUserId, productId);
    } catch (e) {
      print("Gagal toggle fav: $e");
      // Jika gagal, kembalikan state (opsional)
    }
  }

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
          address.value = "Izin Ditolak";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        address.value = "Izin Permanen Ditolak";
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
        // Format alamat yang rapi
        address.value = "${place.subLocality ?? ''}, ${place.locality ?? ''}";
        // Bersihkan koma di awal jika subLocality kosong
        if (address.value.startsWith(", ")) {
          address.value = address.value.substring(2);
        }
      }
    } catch (e) {
      address.value = "Indonesia";
    }
  }
}
