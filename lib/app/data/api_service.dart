import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // =======================================================================
  // KONFIGURASI KONEKSI
  // =======================================================================
  // Ganti URL ini dengan URL Ngrok/Server terbaru Anda
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

  String getProductImageUrl(String productId) {
    return '$_rootUrl/product_image/$productId';
  }

  String getBannerImageUrl(String bannerId) {
    return '$_rootUrl/banner_image/$bannerId';
  }

  // =======================================================================
  // 1. AUTH PENGGUNA
  // =======================================================================

  // Endpoint: /api/registerpengguna
  Future<Map<String, dynamic>> registerPengguna(
    String name,
    String phone,
    String password,
    String email,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/registerpengguna'),
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
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/loginpengguna'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal login: $e'};
    }
  }

  // =======================================================================
  // 2. DATA PRODUK & KATALOG
  // =======================================================================

  // Mengambil semua produk (Route /api/products)
  Future<List<dynamic>> getProducts() async {
    final data = await _getListData('$baseUrl/products');
    return data.map((item) {
      String pid = item['id'].toString();
      item['id'] = pid;
      item['image_url'] = getProductImageUrl(pid);
      item['rating'] = item['rating'] ?? 0.0;
      return item;
    }).toList();
  }

  // Mengambil Katalog dengan Filter (PENTING: Menggunakan endpoint /products)
  Future<List<dynamic>> getCatalog({String? search, String? categoryId}) async {
    // Kita panggil /products karena itu yang tersedia di backend app.py
    // Filter pencarian sebaiknya dilakukan di sisi Client (Controller) untuk performa lebih baik
    // kecuali backend sudah support query param ?search=...

    // Membangun Query String jika backend support
    List<String> queryParams = [];
    if (search != null && search.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search)}');
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams.add('category_id=$categoryId');
    }

    String queryString = '';
    if (queryParams.isNotEmpty) {
      queryString = '?${queryParams.join('&')}';
    }

    // UPDATE: Menggunakan endpoint /products bukan /catalog
    final url = '$baseUrl/products$queryString';

    final data = await _getListData(url);

    return data.map((item) {
      String pid = item['id'].toString();
      item['id'] = pid;
      item['image_url'] = getProductImageUrl(pid);
      item['rating'] = item['rating'] ?? 0.0;
      item['category'] = item['category'] ?? 'Umum';
      return item;
    }).toList();
  }

  // Detail Produk (Route /api/products/<id>)
  Future<Map<String, dynamic>> getProductDetail(
    String productId, {
    String? customerId,
  }) async {
    try {
      String url = '$baseUrl/products/$productId';
      if (customerId != null && customerId.isNotEmpty) {
        url += '?customer_id=$customerId';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      Map<String, dynamic> data = _processGenericResponse(response);

      if (data['status'] == 'success') {
        data['id'] = data['id'].toString();
        data['image_url'] = getProductImageUrl(productId);
        data['description'] = data['description'] ?? 'Tidak ada deskripsi.';
      }
      return data;
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal koneksi detail: $e'};
    }
  }

  // =======================================================================
  // 3. FAVORIT, BANNER & VOUCHER
  // =======================================================================

  // Favorit User
  Future<List<dynamic>> getFavorites(String customerId) async {
    final data = await _getListData('$baseUrl/favorites/$customerId');
    return data.map((item) {
      String pid = item['product_id'].toString();
      item['product_id'] = pid;
      item['image_url'] = getProductImageUrl(pid);
      return item;
    }).toList();
  }

  // Toggle Favorit
  Future<Map<String, dynamic>> toggleFavorite(
    String customerId,
    String productId,
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

  // Banners
  Future<List<dynamic>> getBanners() async {
    final data = await _getListData('$baseUrl/banners');
    return data.map((item) {
      String bid = item['id'].toString();
      item['id'] = bid;
      item['image_url'] = getBannerImageUrl(bid);
      return item;
    }).toList();
  }

  // Vouchers (Hanya SATU deklarasi)
  Future<List<dynamic>> getVouchers() async {
    return await _getListData('$baseUrl/vouchers');
  }

  // Kategori
  Future<List<dynamic>> getCategories() async {
    return await _getListData('$baseUrl/categories');
  }

  // =======================================================================
  // 4. TRANSAKSI (CHECKOUT & REDEEM) & POIN
  // =======================================================================

  // Checkout
  Future<Map<String, dynamic>> checkout({
    required String customerId,
    required List<Map<String, dynamic>> items,
    String? voucherCode,
    String paymentMethod = 'Cash',
  }) async {
    try {
      final processedItems = items.map((item) {
        return {'id': item['id'].toString(), 'qty': item['qty']};
      }).toList();

      final body = {
        'customer_id': customerId,
        'items': processedItems,
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

  // Redeem Poin
  Future<Map<String, dynamic>> redeemPoints({
    required String customerId,
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

  // Rewards (Hadiah Penukaran)
  Future<List<dynamic>> getRewards() async {
    final data = await _getListData('$baseUrl/rewards');
    return data.map((item) {
      String pid = item['id'].toString();
      item['id'] = pid;
      return item;
    }).toList();
  }

  // Cek Poin User
  Future<int> getUserPoints(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user_points/$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return int.tryParse(json['data']['points'].toString()) ?? 0;
        }
      }
    } catch (e) {
      print("Error get points: $e");
    }
    return 0;
  }

  // =======================================================================
  // HELPER INTERNAL (PRIVATE)
  // =======================================================================

  Future<List<dynamic>> _getListData(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);

      // Cek jika response HTML (bukan JSON)
      if (response.body.trim().startsWith("<")) return [];

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is Map<String, dynamic> && json['status'] == 'success') {
          return json['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print("API Error ($url): $e");
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
