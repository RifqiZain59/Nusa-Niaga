import 'package:get/get.dart';
import 'package:nusaniaga/app/data/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = true.obs;

  // Data Master (Backup)
  var products = <dynamic>[].obs;
  // Data Tampil (Hasil Filter)
  var filteredProducts = <dynamic>[].obs;

  var categoryList = <String>[].obs;
  var banners = <dynamic>[].obs;
  var searchQuery = "".obs;
  var address = "Mencari lokasi...".obs;

  final Set<String> _favoriteIds = {};
  final String _customerId = "dummy_user_id";

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    determinePosition();

    // Listener Search: Menggunakan Local Search
    debounce(
      searchQuery,
      (callback) => _searchLocal(),
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading(true);
      var results = await Future.wait([
        _apiService.getBanners(),
        _apiService.getCategories(),
        _apiService.getCatalog(), // Sekarang memanggil /products
        _apiService.getFavorites(_customerId),
      ]);

      var fetchedBanners = results[0] as List<dynamic>;
      var fetchedCategories = results[1] as List<dynamic>;
      var fetchedProducts = results[2] as List<dynamic>;
      var favoriteData = results[3] as List<dynamic>;

      // Setup Kategori
      List<String> tempCategories = ["All"];
      for (var cat in fetchedCategories) {
        tempCategories.add(cat['name'].toString());
      }
      categoryList.assignAll(tempCategories);

      // Setup Favorit
      _favoriteIds.clear();
      for (var fav in favoriteData) {
        _favoriteIds.add(fav['product_id'].toString());
      }

      // Map Produk
      var mappedProducts = _mapFavoritesToProducts(fetchedProducts);

      // Simpan Data
      banners.assignAll(fetchedBanners);
      products.assignAll(mappedProducts); // Simpan ke Master
      filteredProducts.assignAll(mappedProducts); // Simpan ke Tampilan
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: $e");
    } finally {
      isLoading(false);
    }
  }

  // LOGIC SEARCH LOKAL (Lebih Cepat & Stabil)
  void _searchLocal() {
    String query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredProducts.assignAll(products);
    } else {
      var result = products.where((p) {
        String name = (p['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
      filteredProducts.assignAll(result);
    }
  }

  List<dynamic> _mapFavoritesToProducts(List<dynamic> rawProducts) {
    return rawProducts.map((product) {
      String pid = product['id'].toString();
      product['is_favorite'] = _favoriteIds.contains(pid);
      return product;
    }).toList();
  }

  Future<void> toggleFavorite(String productId) async {
    // ... Logika sama seperti sebelumnya ...
    // Update lokal _favoriteIds dan refresh UI
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    _searchLocal(); // Refresh tampilan saat ini
    _apiService.toggleFavorite(
      _customerId,
      productId,
    ); // Kirim ke server di background
  }

  Future<void> determinePosition() async {
    // ... Logika Geolocation sama seperti sebelumnya ...
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        address.value = "GPS Mati";
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        address.value =
            "${placemarks[0].subLocality}, ${placemarks[0].locality}";
      }
    } catch (_) {
      address.value = "Indonesia";
    }
  }
}
