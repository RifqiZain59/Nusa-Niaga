import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // =======================================================================
  // KONFIGURASI KONEKSI
  // =======================================================================
  // Ganti URL ini dengan URL Ngrok terbaru Anda setiap kali restart Ngrok
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
    return '$baseUrl/product_image/$productId';
  }

  String getBannerImageUrl(String bannerId) {
    return '$baseUrl/banner_image/$bannerId';
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

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String name,
    required String email,
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
      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }

      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'avatar',
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal update profil: $e'};
    }
  }

  // =======================================================================
  // 2. DATA PRODUK, DETAIL & KATALOG
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
      print("Error getProducts: $e");
      return [];
    }
  }

  // Digunakan untuk pencarian/katalog (Mapping ke /products karena /catalog tidak ada di backend)
  Future<List<dynamic>> getCatalog({String? search, String? categoryId}) async {
    try {
      // Kita ambil semua produk dulu, filter dilakukan di sisi Flutter (atau backend jika support search)
      // Saat ini backend hanya support get all products, jadi kita ambil semua.
      final list = await getProducts();

      // Filter manual di sisi client jika backend belum support query param
      // Jika backend sudah diupdate untuk support ?search=..., kode ini akan tetap bekerja
      return list.where((item) {
        bool matchSearch = true;
        bool matchCategory = true;

        if (search != null && search.isNotEmpty) {
          matchSearch = item['name'].toString().toLowerCase().contains(
            search.toLowerCase(),
          );
        }
        if (categoryId != null && categoryId.isNotEmpty) {
          // Asumsi item punya field category_id
          matchCategory =
              item['category_id'].toString() == categoryId.toString();
        }

        return matchSearch && matchCategory;
      }).toList();
    } catch (e) {
      print("Error getCatalog: $e");
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
          product['description'] =
              product['description'] ?? 'Tidak ada deskripsi.';
          // Pastikan is_favorite ada defaultnya
          product['is_favorite'] = product['is_favorite'] ?? false;
          return product;
        }
      }
      return data;
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal koneksi detail: $e'};
    }
  }

  // =======================================================================
  // 3. TRANSAKSI & CHECKOUT (PENTING)
  // =======================================================================

  Future<Map<String, dynamic>> checkout({
    required String customerId,
    required List<Map<String, dynamic>> items,
    String? voucherCode,
    String paymentMethod = 'Cash',
    String? tableNumber, // Tambahkan parameter ini
    double? discount, // Kirim nominal diskon jika ada
  }) async {
    try {
      final processedItems = items.map((item) {
        return {
          'product_id': item['id'].toString(),
          'qty': int.parse(item['qty'].toString()),
        };
      }).toList();

      final body = {
        'customer_id': customerId, // Backend akan membacanya sebagai user_id
        'table_number': tableNumber ?? '-', // Kirim Nomor Meja
        'items': processedItems,
        'voucher_code': voucherCode,
        'payment_method': paymentMethod,
        'order_id': 'TRX-${DateTime.now().millisecondsSinceEpoch}',
        // Kirim summary agar backend tau diskonnya (opsional, backend hitung ulang gross)
        'summary': {'discount': discount ?? 0},
      };

      print("Sending Checkout: ${jsonEncode(body)}");

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

  // Alias agar kompatibel dengan Controller yang mungkin memanggil createTransaction
  Future<Map<String, dynamic>> createTransaction({
    required String customerId,
    required String customerName,
    required double totalAmount,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    String? voucherCode,
    String? tableNumber,
  }) async {
    // Redirect logic ke fungsi checkout yang sudah baku
    return await checkout(
      customerId: customerId,
      items: items,
      voucherCode: voucherCode,
      paymentMethod: paymentMethod,
    );
  }

  Future<List<dynamic>> getTransactionHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transaction_history/$userId'),
        headers: _headers,
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
  // 4. FITUR LAIN (Banner, Voucher, Review, dsb)
  // =======================================================================

  Future<List<dynamic>> getBanners() async {
    final data = await _getListData('$baseUrl/banners');
    return data.map((item) {
      String bid = item['id'].toString();
      item['image_url'] = getBannerImageUrl(bid);
      return item;
    }).toList();
  }

  Future<List<dynamic>> getVouchers() async {
    return await _getListData('$baseUrl/vouchers');
  }

  Future<List<dynamic>> getRewards() async {
    return await _getListData('$baseUrl/rewards');
  }

  Future<int> getUserPoints(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user_points/$userId'),
        headers: _headers, // Pastikan header json ada
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return int.tryParse(json['data']['points'].toString()) ?? 0;
        }
      }
      return 0;
    } catch (e) {
      print("Error get points: $e");
      return 0;
    }
  }

  Future<List<dynamic>> getPointHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/point_history/$userId'),
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
      print("Error get history: $e");
      return [];
    }
  }

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
          'qty': qty, // [BARU] Kirim qty ke backend
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getCategories() async {
    return await _getListData('$baseUrl/categories');
  }

  // Placeholder jika endpoint favorite belum ada di backend
  // Agar tidak error, kembalikan list kosong
  Future<List<dynamic>> getFavorites(String customerId) async {
    return []; // <--- Ini penyebabnya! Selalu kosong.
  }

  Future<Map<String, dynamic>> toggleFavorite(
    String customerId,
    String productId,
  ) async {
    // Placeholder logic
    return {
      'status': 'success',
      'message': 'Fitur favorit belum aktif di server',
    };
  }

  // =======================================================================
  // INTERNAL HELPER
  // =======================================================================

  Future<List<dynamic>> _getListData(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.body.trim().startsWith("<")) return []; // Handle error HTML

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
}
