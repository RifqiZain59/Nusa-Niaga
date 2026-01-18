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
  var isReloading = false.obs;

  var userName = "Pengguna".obs;
  var address = "Mencari lokasi...".obs;

  var allProducts = <dynamic>[].obs;
  var filteredProducts = <dynamic>[].obs;
  var categoryList = <String>[].obs;
  var banners = <dynamic>[].obs;

  var searchQuery = "".obs;
  var selectedCategory = "All".obs;

  final Set<String> _favoriteIds = {};
  String _currentUserId = "";

  @override
  void onInit() {
    super.onInit();
    fetchHomeData(isRefresh: false);
    determinePosition();

    debounce(
      searchQuery,
      (_) => _applyFilters(),
      time: const Duration(milliseconds: 500),
    );
    ever(selectedCategory, (_) => _applyFilters());
  }

  Future<void> fetchHomeData({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isReloading.value = true;
      } else {
        isLoading.value = true;
      }

      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id') ?? '';

      String savedName = prefs.getString('user_name') ?? 'Pengguna';
      List<String> names = savedName.split(' ');
      userName.value = names.isNotEmpty ? names[0] : savedName;

      // [PERBAIKAN] Cara deklarasi Future List agar Type Safe
      // Kita buat list explicit berisi Future<dynamic>
      List<Future<dynamic>> futures = [
        _apiService.getBanners(), // Index 0
        _apiService.getCategories(), // Index 1
        _apiService.getProducts(), // Index 2
      ];

      // Tambahkan future favorit secara kondisional
      if (_currentUserId.isNotEmpty) {
        futures.add(_apiService.getFavorites(_currentUserId)); // Index 3
      } else {
        futures.add(Future.value([])); // Placeholder agar index tetap konsisten
      }

      // Eksekusi Paralel
      var results = await Future.wait(futures);

      if (isRefresh) await Future.delayed(const Duration(milliseconds: 800));

      var fetchedBanners = results[0] as List<dynamic>;
      var fetchedCategories = results[1] as List<dynamic>;
      var fetchedProducts = results[2] as List<dynamic>;
      var favoriteData = results[3] as List<dynamic>;

      // Setup Kategori
      List<String> tempCats = ["All"];
      for (var item in fetchedCategories) {
        tempCats.add(item['name'].toString());
      }
      categoryList.assignAll(tempCats);

      // Setup Favorit
      _favoriteIds.clear();
      for (var fav in favoriteData) {
        // Backend mengirim 'product_id', pastikan sesuai
        var pid = fav['product_id'] ?? fav['id'];
        if (pid != null) _favoriteIds.add(pid.toString());
      }

      var processedProducts = _mapFavoritesToProducts(fetchedProducts);

      banners.assignAll(fetchedBanners);
      allProducts.assignAll(processedProducts);

      _applyFilters();
    } catch (e) {
      print("Error Fetch Home: $e");
    } finally {
      if (isRefresh) {
        isReloading.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshHomeData() async {
    await fetchHomeData(isRefresh: true);
    determinePosition();
  }

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

    // Optimistic UI Update
    allProducts.value = _mapFavoritesToProducts(allProducts);
    _applyFilters();

    try {
      await _apiService.toggleFavorite(_currentUserId, productId);
    } catch (e) {
      print("Gagal toggle fav: $e");
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
        address.value = "${place.subLocality ?? ''}, ${place.locality ?? ''}";
        if (address.value.startsWith(", ")) {
          address.value = address.value.substring(2);
        }
      }
    } catch (e) {
      address.value = "Indonesia";
    }
  }
}
