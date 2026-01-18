import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // =======================================================================
  // KONFIGURASI KONEKSI
  // =======================================================================
  // PENTING: Ganti URL ini dengan URL Ngrok terbaru Anda setiap kali restart Ngrok
  static const String baseUrl =
      'https://undepraved-jaiden-nonflexibly.ngrok-free.dev/api';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // =======================================================================
  // HELPER GAMBAR
  // =======================================================================
  String getProductImageUrl(String productId) =>
      '$baseUrl/product_image/$productId';

  String getBannerImageUrl(String bannerId) =>
      '$baseUrl/banner_image/$bannerId';

  String getCustomerImageUrl(String customerId) =>
      '$baseUrl/customer_image/$customerId';

  // =======================================================================
  // 1. AUTH PENGGUNA (Register, Login, Google, Profile)
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

  // [METHOD BARU] Login Google Sync ke Backend
  Future<Map<String, dynamic>> loginGoogle({
    required String uid,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login_google'),
        headers: _headers,
        body: jsonEncode({
          'uid': uid,
          'email': email,
          'name': name,
          'photo_url': photoUrl,
        }),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal login Google: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String name,
    required String email,
    String? phone, // [BARU]
    String? password,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/update_profile'),
      );
      request.headers.addAll({
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      });

      request.fields['user_id'] = userId;
      request.fields['name'] = name;
      request.fields['email'] = email;

      // [BARU] Kirim Phone jika ada
      if (phone != null) request.fields['phone'] = phone;

      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }

      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        request.files.add(
          http.MultipartFile(
            'avatar',
            stream,
            length,
            filename: imageFile.path.split('/').last,
          ),
        );
      }

      var res = await request.send();
      return _processResponse(await http.Response.fromStream(res));
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal update profil: $e'};
    }
  }

  // [BARU] Method Hapus Akun
  Future<bool> deleteAccount(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_account'),
        headers: _headers,
        body: jsonEncode({'user_id': userId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> loginViaUid(String uid) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login_via_uid'),
        headers: _headers,
        body: jsonEncode({'uid': uid}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal sinkronisasi user: $e'};
    }
  }

  // =======================================================================
  // 2. DATA PRODUK & FAVORIT
  // =======================================================================

  Future<List<dynamic>> getProducts() async {
    try {
      final list = await _getListData('$baseUrl/products');
      return list.map((item) {
        String id = item['id'].toString();
        item['image_url'] = getProductImageUrl(id);
        return item;
      }).toList();
    } catch (e) {
      return [];
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
          product['is_favorite'] = product['is_favorite'] ?? false;
          return product;
        }
      }
      return data;
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal koneksi detail: $e'};
    }
  }

  // [METHOD BARU] Get Favorites
  Future<List<dynamic>> getFavorites(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return json['data'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      print("Error getFavorites: $e");
      return [];
    }
  }

  // [METHOD BARU] Toggle Favorite
  Future<bool> toggleFavorite(String userId, String productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/favorites/toggle'),
        headers: _headers,
        body: jsonEncode({'user_id': userId, 'product_id': productId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getCategories() async {
    return await _getListData('$baseUrl/categories');
  }

  // =======================================================================
  // 3. TRANSAKSI (Checkout & History)
  // =======================================================================

  Future<Map<String, dynamic>> checkout({
    required String customerId,
    required List<Map<String, dynamic>> items, // Menerima List Map
    String? voucherCode,
    String paymentMethod = 'Cash',
    String? tableNumber,
    double? discount,
  }) async {
    try {
      // Pastikan format item sesuai yang diharapkan backend
      final processedItems = items.map((item) {
        return {
          'product_id': item['id'].toString(), // id produk
          'qty': int.parse(item['qty'].toString()), // jumlah
        };
      }).toList();

      final body = {
        'customer_id': customerId,
        'table_number': tableNumber ?? '-',
        'items': processedItems,
        'voucher_code': voucherCode,
        'payment_method': paymentMethod,
        'order_id': 'TRX-${DateTime.now().millisecondsSinceEpoch}',
        'summary': {'discount': discount ?? 0},
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

  Future<List<dynamic>> getTransactionHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transaction_history/$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') return data['data'] as List<dynamic>;
      }
    } catch (e) {
      print("Error history: $e");
    }
    return [];
  }

  // =======================================================================
  // 4. FITUR LAIN (Poin, Voucher, Review, Banner)
  // =======================================================================

  Future<List<dynamic>> getBanners() async {
    final data = await _getListData('$baseUrl/banners');
    return data.map((item) {
      item['image_url'] = getBannerImageUrl(item['id'].toString());
      return item;
    }).toList();
  }

  Future<List<dynamic>> getVouchers() async {
    return await _getListData('$baseUrl/vouchers');
  }

  Future<List<dynamic>> getRewards() async {
    return await _getListData('$baseUrl/rewards');
  }

  // [METHOD BARU] Get User Points
  Future<int> getUserPoints(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user_points/$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          // Parsing aman ke int
          return int.tryParse(json['data']['points'].toString()) ?? 0;
        }
      }
    } catch (_) {}
    return 0;
  }

  // [METHOD BARU] Get Point History
  Future<List<dynamic>> getPointHistory(String userId) async {
    return await _getListData('$baseUrl/point_history/$userId');
  }

  // [METHOD BARU] Redeem Via Scan QR
  Future<Map<String, dynamic>> redeemViaScan(
    String userId,
    int points,
    String itemName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/redeem_via_scan'),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
          'points': points,
          'item_name': itemName,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // [METHOD BARU] Add Review
  Future<bool> addReview(
    String userId,
    String productId,
    int rating, {
    String comment = '',
    int qty = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_review'),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
          'rating': rating,
          'comment': comment,
          'qty': qty,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // =======================================================================
  // INTERNAL HELPER
  // =======================================================================

  Future<List<dynamic>> _getListData(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);

      // Cek jika response HTML (Error server/ngrok)
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
      return {'status': 'error', 'message': 'Format respon salah: $e'};
    }
  }

  Map<String, dynamic> _processGenericResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return {'status': 'error', 'message': 'Respon tidak valid'};
      } catch (_) {
        return {'status': 'error', 'message': 'Gagal decode JSON'};
      }
    }
    return {'status': 'error', 'message': 'Error ${response.statusCode}'};
  }
}
