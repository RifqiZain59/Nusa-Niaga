import 'package:get/get.dart';
import 'package:nusaniaga/app/data/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = true.obs;

  // 'products' menyimpan data master (backup data awal)
  var products = <dynamic>[].obs;

  // 'filteredProducts' adalah data yang aktif ditampilkan (hasil search atau data awal)
  var filteredProducts = <dynamic>[].obs;

  // List Kategori Dinamis dari Database
  var categoryList = <String>[].obs;

  var banners = <dynamic>[].obs;
  var searchQuery = "".obs;
  var address = "Mencari lokasi...".obs;
  var currentBannerIndex = 0.obs;

  // Set untuk menyimpan ID produk yang difavoritkan agar sinkron
  final Set<int> _favoriteIds = {};

  // ID Customer (Sesuaikan dengan session login nantinya)
  final int _customerId = 1;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    determinePosition();

    // Listener Search: Tunggu 500ms setelah mengetik, lalu cari ke server
    debounce(
      searchQuery,
      (callback) => searchProductsServerSide(),
      time: const Duration(milliseconds: 500),
    );
  }

  // --- 1. AMBIL DATA AWAL (BANNER, KATEGORI, PRODUK) ---
  Future<void> fetchHomeData() async {
    try {
      isLoading(true);

      // Request API secara paralel
      var fetchedBanners = await _apiService.getBanners();
      var fetchedCategories = await _apiService
          .getCategories(); // Ambil Kategori DB
      var fetchedProducts = await _apiService.getCatalog(); // Ambil Produk Awal
      var favoriteData = await _apiService.getFavorites(_customerId);

      // A. Proses Kategori (Tambahkan "All" di paling depan)
      List<String> tempCategories = ["All"];
      for (var cat in fetchedCategories) {
        tempCategories.add(cat['name'].toString());
      }
      categoryList.assignAll(tempCategories);

      // B. Proses Favorit
      _favoriteIds.clear();
      if (favoriteData is List) {
        for (var fav in favoriteData) {
          _favoriteIds.add(fav['product_id']);
        }
      }

      // C. Mapping Status Favorit ke Produk
      var mappedProducts = _mapFavoritesToProducts(fetchedProducts);

      // D. Simpan ke State
      banners.assignAll(fetchedBanners);
      products.assignAll(mappedProducts); // Backup
      filteredProducts.assignAll(mappedProducts); // Tampil
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- 2. PENCARIAN SERVER-SIDE ---
  Future<void> searchProductsServerSide() async {
    String query = searchQuery.value;

    // Jika search kosong, kembalikan ke data awal
    if (query.isEmpty) {
      filteredProducts.assignAll(products);
      return;
    }

    try {
      isLoading(true);

      // Panggil API search
      var searchResults = await _apiService.getCatalog(search: query);

      // Mapping status favorit ke hasil pencarian baru
      var mappedResults = _mapFavoritesToProducts(searchResults);

      // Update tampilan
      filteredProducts.assignAll(mappedResults);
    } catch (e) {
      print("Error searching: $e");
      filteredProducts.clear();
    } finally {
      isLoading(false);
    }
  }

  // Helper: Mapping status favorit ke list produk apapun
  List<dynamic> _mapFavoritesToProducts(List<dynamic> rawProducts) {
    return rawProducts.map((product) {
      product['is_favorite'] = _favoriteIds.contains(product['id']);
      return product;
    }).toList();
  }

  // --- 3. TOGGLE FAVORIT ---
  Future<void> toggleFavorite(int productId) async {
    try {
      final result = await _apiService.toggleFavorite(_customerId, productId);

      if (result['status'] != 'error') {
        // Update di Set Global
        if (_favoriteIds.contains(productId)) {
          _favoriteIds.remove(productId);
        } else {
          _favoriteIds.add(productId);
        }

        // Update UI filteredProducts (yang sedang dilihat)
        int indexFiltered = filteredProducts.indexWhere(
          (p) => p['id'] == productId,
        );
        if (indexFiltered != -1) {
          filteredProducts[indexFiltered]['is_favorite'] = _favoriteIds
              .contains(productId);
          filteredProducts.refresh();
        }

        // Update UI products (data backup)
        int indexMaster = products.indexWhere((p) => p['id'] == productId);
        if (indexMaster != -1) {
          products[indexMaster]['is_favorite'] = _favoriteIds.contains(
            productId,
          );
        }
      }
    } catch (e) {
      print("Gagal toggle favorite: $e");
    }
  }

  // --- 4. LOKASI (GPS) ---
  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        address.value = "GPS tidak aktif";
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          address.value = "Izin lokasi ditolak";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        address.value = "Izin lokasi diblokir";
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
      }
    } catch (e) {
      address.value = "Gagal mengambil lokasi";
    }
  }

  void updateBannerIndex(int index) {
    currentBannerIndex.value = index;
  }
}
