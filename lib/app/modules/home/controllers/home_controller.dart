import 'package:get/get.dart';
import 'package:nusaniaga/app/data/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = true.obs;
  var banners = <dynamic>[].obs;
  var products = <dynamic>[].obs;

  // Variabel untuk fitur pencarian
  var filteredProducts = <dynamic>[].obs; // List yang ditampilkan di UI
  var searchQuery = "".obs; // Menampung input teks dari search bar

  var address = "Mencari lokasi...".obs;
  var currentBannerIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    determinePosition();

    // Listener otomatis: Jalankan filter saat searchQuery berubah
    // Debounce menunggu 300ms setelah user berhenti mengetik agar tidak lag
    debounce(
      searchQuery,
      (_) => filterProducts(),
      time: const Duration(milliseconds: 300),
    );
  }

  // --- FUNGSI AMBIL DATA HOME & FAVORIT ---
  Future<void> fetchHomeData() async {
    try {
      isLoading(true);

      var fetchedBanners = await _apiService.getBanners();
      var fetchedProducts = await _apiService.getProducts();

      const int customerId = 1;
      var favoriteData = await _apiService.getFavorites(customerId);

      Set<int> favoriteIds = {};
      if (favoriteData is List) {
        for (var fav in favoriteData) {
          favoriteIds.add(fav['product_id']);
        }
      }

      var mappedProducts = fetchedProducts.map((product) {
        product['is_favorite'] = favoriteIds.contains(product['id']);
        return product;
      }).toList();

      banners.assignAll(fetchedBanners);
      products.assignAll(mappedProducts);

      // Inisialisasi awal list hasil filter dengan semua produk
      filterProducts();
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- LOGIKA PENCARIAN PRODUK ---
  void filterProducts() {
    if (searchQuery.value.isEmpty) {
      // Jika kolom cari kosong, tampilkan semua produk
      filteredProducts.assignAll(products);
    } else {
      // Saring produk berdasarkan nama (case-insensitive)
      filteredProducts.assignAll(
        products
            .where(
              (p) => p['name'].toString().toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
            )
            .toList(),
      );
    }
  }

  // FUNGSI UNTUK TOGGLE FAVORIT
  Future<void> toggleFavorite(int productId) async {
    try {
      const int customerId = 1;
      final result = await _apiService.toggleFavorite(customerId, productId);

      if (result['status'] != 'error') {
        int index = products.indexWhere((p) => p['id'] == productId);
        if (index != -1) {
          // Update status lokal
          products[index]['is_favorite'] = !products[index]['is_favorite'];
          products.refresh();

          // REFRESH OTOMATIS: Jalankan ulang filter agar tampilan Grid langsung berubah
          filterProducts();
        }
      }
    } catch (e) {
      print("Gagal toggle favorite: $e");
    }
  }

  // --- FUNGSI LOKASI ---
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
