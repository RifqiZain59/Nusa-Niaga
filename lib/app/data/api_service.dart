import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // =======================================================================
  // KONFIGURASI KONEKSI
  // =======================================================================
  // Pastikan URL ini sesuai dengan URL Ngrok terbaru Anda
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

  Future<List<dynamic>> getProductReviews(String productId) async {
    return await _getListData('$baseUrl/reviews/$productId');
  }

  // =======================================================================
  // 1. AUTH PENGGUNA
  // =======================================================================

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

  // Alias untuk kompatibilitas dengan RegisterController lama
  Future<Map<String, dynamic>?> registrasiPengguna(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    return await registerPengguna(name, phone, password, email);
  }

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
  // 2. DATA PRODUK & DETAIL
  // =======================================================================

  Future<List<dynamic>> getProducts() async {
    try {
      final list = await _getListData('$baseUrl/products');

      // Transform data: Tambahkan URL Gambar lengkap
      return list.map((item) {
        // Pastikan ID ada dan dikonversi ke String
        String id = item['id'].toString();

        // Buat URL Gambar manual mengarah ke endpoint Flask
        // Tambahkan timestamp (?v=...) agar gambar tidak cache jika berubah
        item['image_url'] = '$baseUrl/product_image/$id';

        return item;
      }).toList();
    } catch (e) {
      print("Error getProducts: $e");
      return []; // Return list kosong agar aplikasi tidak crash
    }
  }

  Future<bool> addReview(String userId, String productId, int rating) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
          'rating': rating,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

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
        var product = data['data'] ?? data;
        if (product is Map<String, dynamic>) {
          product['id'] = product['id'].toString();
          product['image_url'] = getProductImageUrl(productId);
          product['description'] =
              product['description'] ?? 'Tidak ada deskripsi.';
          return product;
        }
      }
      return data;
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal koneksi detail: $e'};
    }
  }

  // =======================================================================
  // 3. FAVORIT & BANNER & VOUCHER
  // =======================================================================

  Future<List<dynamic>> getFavorites(String customerId) async {
    final data = await _getListData('$baseUrl/favorites/$customerId');
    return data.map((item) {
      String pid = item['product_id'].toString();
      item['product_id'] = pid;
      item['image_url'] = getProductImageUrl(pid);
      return item;
    }).toList();
  }

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

  Future<List<dynamic>> getBanners() async {
    final data = await _getListData('$baseUrl/banners');
    return data.map((item) {
      String bid = item['id'].toString();
      item['id'] = bid;
      item['image_url'] = getBannerImageUrl(bid);
      return item;
    }).toList();
  }

  Future<List<dynamic>> getVouchers() async {
    return await _getListData('$baseUrl/vouchers');
  }

  // =======================================================================
  // 4. TRANSAKSI, POIN & REWARDS
  // =======================================================================

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

  // Alias untuk PaymentController
  Future<Map<String, dynamic>> createTransaction({
    required String customerId,
    required String customerName,
    required double totalAmount,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    String? voucherCode,
    String? tableNumber,
  }) async {
    try {
      final bodyData = {
        'customer_id': customerId,
        'customer_name': customerName,
        'final_price': totalAmount,
        'payment_method': paymentMethod,
        'items': items,
        'voucher_code': voucherCode,
        'table_number': tableNumber ?? 'Take Away',
      };

      // PERBAIKAN: Menggunakan endpoint /checkout yang benar
      final response = await http.post(
        Uri.parse('$baseUrl/checkout'),
        headers: _headers,
        body: jsonEncode(bodyData),
      );

      return _processResponse(response);
    } catch (e) {
      print("Checkout Error: $e");
      return {'status': 'error', 'message': 'Gagal memproses transaksi'};
    }
  }

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

  Future<int> getUserPoints(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user_points/$userId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return int.tryParse(data['data']['points'].toString()) ?? 0;
        }
      }
    } catch (e) {
      print("Error get points: $e");
    }
    return 0;
  }

  Future<List<dynamic>> getRewards() async {
    return await _getListData('$baseUrl/rewards');
  }

  // PERBAIKAN: Menggunakan endpoint /transactions dengan query param
  Future<List<dynamic>> getTransactionHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transaction_history/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'] as List<dynamic>;
        }
      }
    } catch (e) {
      print("Error get history: $e");
    }
    return [];
  }
  // =======================================================================
  // 5. KATALOG & KATEGORI
  // =======================================================================

  Future<List<dynamic>> getCategories() async {
    return await _getListData('$baseUrl/categories');
  }

  Future<List<dynamic>> getCatalog({String? search, String? categoryId}) async {
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

    final url = '$baseUrl/catalog$queryString';
    final data = await _getListData(url);

    return data.map((item) {
      String pid = item['id'].toString();
      item['id'] = pid;
      item['image_url'] = getProductImageUrl(pid);
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
      print("API Error: $e");
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
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'status': 'error', 'message': 'Format respon bukan JSON Object'};
    } catch (e) {
      return {'status': 'error', 'message': 'Format respon tidak valid: $e'};
    }
  }

  Map<String, dynamic> _processGenericResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return {'status': 'error', 'message': 'Respon tidak valid'};
      } catch (_) {
        return {'status': 'error', 'message': 'Gagal decode JSON'};
      }
    } else if (response.statusCode == 404) {
      return {'status': 'error', 'message': 'Data tidak ditemukan (404)'};
    } else {
      return {'status': 'error', 'message': 'Error: ${response.statusCode}'};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String name,
    required String email,
    String? password,
    File? imageFile, // Parameter File Gambar
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$baseUrl/update_profile',
        ), // Pastikan endpoint ini ada di app.py
      );

      // Header
      request.headers.addAll({
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      });

      // Field Teks
      request.fields['user_id'] = userId;
      request.fields['name'] = name;
      request.fields['email'] = email;
      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }

      // Field Gambar (Jika user memilih gambar baru)
      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'avatar', // Nama field harus sesuai dengan backend (request.files['avatar'])
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Kirim Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal upload: $e'};
    }
  }
}
