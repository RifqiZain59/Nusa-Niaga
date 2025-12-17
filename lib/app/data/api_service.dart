import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // =======================================================================
  // KONFIGURASI KONEKSI (NGROK)
  // =======================================================================
  static const String baseUrl =
      'https://undepraved-jaiden-nonflexibly.ngrok-free.dev/api';

  String get _rootUrl => baseUrl.replaceAll('/api', '');

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // =======================================================================
  // HELPER GAMBAR
  // =======================================================================

  String getProductImageUrl(int productId) {
    return '$_rootUrl/product_image/$productId';
  }

  String getBannerImageUrl(int bannerId) {
    return '$_rootUrl/banner_image/$bannerId';
  }

  // =======================================================================
  // 1. DATA PRODUK (LIST & SINGLE)
  // =======================================================================

  // Ambil SEMUA produk untuk HomeView
  Future<List<dynamic>> getProducts() async {
    final data = await _getListData('$baseUrl/products');
    return data.map((item) {
      item['image_url'] = getProductImageUrl(item['id']);
      item['rating'] = item['rating'] ?? 4.5;
      item['category'] = item['category'] ?? 'Coffee';
      return item;
    }).toList();
  }

  // AMBIL SATU PRODUK (PENTING: customer_id dinamis agar status LIKE tidak hilang)
  Future<Map<String, dynamic>> getProductDetail(
    int productId, {
    int customerId = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId?customer_id=$customerId'),
        headers: _headers,
      );

      final data = _processResponse(response);
      if (data['status'] != 'error') {
        data['image_url'] = getProductImageUrl(productId);
        // Fallback deskripsi jika null agar UI tidak error
        data['description'] =
            data['description'] ?? 'No description available.';
      }
      return data;
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal koneksi detail: $e'};
    }
  }

  // =======================================================================
  // 2. FAVORIT (PENTING: Digunakan oleh HomeController)
  // =======================================================================

  // Ambil daftar favorit user tertentu
  Future<List<dynamic>> getFavorites(int customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/$customerId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Menambah atau menghapus produk dari daftar favorit (toggleFavorite).
  Future<Map<String, dynamic>> toggleFavorite(
    int customerId,
    int productId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/toggle_favorite'),
        headers: _headers,
        body: jsonEncode({'customer_id': customerId, 'product_id': productId}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Error Favorite: $e'};
    }
  }

  // =======================================================================
  // 3. BANNER & AUTH
  // =======================================================================

  Future<List<dynamic>> getBanners() async {
    final data = await _getListData('$baseUrl/banners');
    return data.map((item) {
      item['image_url'] = getBannerImageUrl(item['id']);
      return item;
    }).toList();
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal login: $e'};
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String phone,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: jsonEncode({'name': name, 'phone': phone, 'password': password}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal register: $e'};
    }
  }

  // =======================================================================
  // HELPER INTERNAL
  // =======================================================================

  Future<List<dynamic>> _getListData(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.body.trim().startsWith("<")) return [];
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is List) return json;
        if (json is Map<String, dynamic> && json.containsKey('data')) {
          return json['data'];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getVouchers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vouchers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.body.isEmpty || response.body.trim().startsWith("<")) {
      return {
        'status': 'error',
        'message':
            'Server tidak merespon JSON (Status: ${response.statusCode})',
      };
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return {'status': 'error', 'message': 'Data tidak ditemukan (404)'};
    } else {
      try {
        final errJson = jsonDecode(response.body);
        return {
          'status': 'error',
          'message': errJson['message'] ?? 'Error: ${response.statusCode}',
        };
      } catch (_) {
        return {
          'status': 'error',
          'message': 'Terjadi kesalahan sistem (${response.statusCode})',
        };
      }
    }
  }
}
