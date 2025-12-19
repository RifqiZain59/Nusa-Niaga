import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // =======================================================================
  // KONFIGURASI KONEKSI
  // Ganti URL ini dengan URL Ngrok terbaru Anda setiap kali restart Ngrok
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
  // 1. AUTH PENGGUNA (LOGIN & REGISTER KHUSUS USER)
  // =======================================================================

  // Endpoint: /api/registerpengguna
  Future<Map<String, dynamic>> registerPengguna(
    String name,
    String phone,
    String password, {
    String? email, // Opsional: Ditambahkan sesuai backend baru
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/registerpengguna'), // Endpoint DIUBAH
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'password': password,
          'email': email,
        }),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal register: $e'};
    }
  }

  // Endpoint: /api/loginpengguna
  Future<Map<String, dynamic>> loginPengguna(
    String phone,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/loginpengguna'), // Endpoint DIUBAH
        headers: _headers,
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal login: $e'};
    }
  }

  // =======================================================================
  // 2. DATA PRODUK & DETAIL
  // =======================================================================

  // Sesuai route /api/products
  Future<List<dynamic>> getProducts() async {
    final data = await _getListData('$baseUrl/products');
    return data.map((item) {
      item['image_url'] = getProductImageUrl(item['id']);
      item['rating'] = item['rating'] ?? 0.0;
      return item;
    }).toList();
  }

  // Sesuai route /api/products/<id>
  Future<Map<String, dynamic>> getProductDetail(
    int productId, {
    int customerId = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId?customer_id=$customerId'),
        headers: _headers,
      );

      Map<String, dynamic> data = _processGenericResponse(response);

      if (data['status'] == 'success') {
        data['image_url'] = getProductImageUrl(productId);
        data['description'] = data['description'] ?? 'Tidak ada deskripsi.';
      }
      return data;
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal koneksi detail: $e'};
    }
  }

  // =======================================================================
  // 3. FAVORIT & BANNER & VOUCHER
  // =======================================================================

  // Sesuai route /api/favorites/<customer_id>
  Future<List<dynamic>> getFavorites(int customerId) async {
    final data = await _getListData('$baseUrl/favorites/$customerId');
    return data.map((item) {
      item['image_url'] = getProductImageUrl(item['product_id']);
      return item;
    }).toList();
  }

  // Sesuai route /api/toggle_favorite
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

  // Sesuai route /api/banners
  Future<List<dynamic>> getBanners() async {
    final data = await _getListData('$baseUrl/banners');
    return data.map((item) {
      item['image_url'] = getBannerImageUrl(item['id']);
      return item;
    }).toList();
  }

  // Sesuai route /api/vouchers
  Future<List<dynamic>> getVouchers() async {
    return await _getListData('$baseUrl/vouchers');
  }

  // =======================================================================
  // 4. TRANSAKSI (CHECKOUT & REDEEM)
  // =======================================================================

  // Sesuai route /api/checkout
  Future<Map<String, dynamic>> checkout({
    required int customerId,
    required List<Map<String, dynamic>> items,
    String? voucherCode,
    String paymentMethod = 'Cash',
  }) async {
    try {
      final body = {
        'customer_id': customerId,
        'items': items,
        'voucher_code': voucherCode,
        'payment_method': paymentMethod,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/checkout'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal checkout: $e'};
    }
  }

  // Sesuai route /api/redeem
  Future<Map<String, dynamic>> redeemPoints({
    required int customerId,
    required int points,
    String description = 'Penukaran via Aplikasi',
  }) async {
    try {
      final body = {
        'customer_id': customerId,
        'points': points,
        'description': description,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/redeem'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal redeem: $e'};
    }
  }

  // =======================================================================
  // 5. KATALOG & KATEGORI
  // =======================================================================

  Future<List<dynamic>> getCategories() async {
    return await _getListData('$baseUrl/categories');
  }

  Future<List<dynamic>> getCatalog({String? search, int? categoryId}) async {
    List<String> queryParams = [];

    if (search != null && search.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search)}');
    }
    if (categoryId != null) {
      queryParams.add('category_id=$categoryId');
    }

    String queryString = '';
    if (queryParams.isNotEmpty) {
      queryString = '?${queryParams.join('&')}';
    }

    final url = '$baseUrl/catalog$queryString';
    final data = await _getListData(url);

    return data.map((item) {
      item['image_url'] = getProductImageUrl(item['id']);
      item['rating'] = item['rating'] ?? 0.0;
      return item;
    }).toList();
  }

  // =======================================================================
  // HELPER INTERNAL (PRIVATE)
  // =======================================================================

  Future<List<dynamic>> _getListData(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.body.trim().startsWith("<")) return [];
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is Map<String, dynamic> && json['status'] == 'success') {
          return json['data'] ?? [];
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
        'message': 'Server Error (Status: ${response.statusCode})',
      };
    }
    try {
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Format respon tidak valid'};
    }
  }

  Map<String, dynamic> _processGenericResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return {'status': 'error', 'message': 'Data tidak ditemukan (404)'};
    } else {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {'status': 'error', 'message': 'Error: ${response.statusCode}'};
      }
    }
  }
}
