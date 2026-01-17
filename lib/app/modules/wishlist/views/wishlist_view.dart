import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // [WAJIB] Untuk tipe Timestamp
import 'package:ionicons/ionicons.dart';
import '../controllers/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  static const Color _primaryColor = Color(0xFF2563EB);
  static const Color _bgColor = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller di-put
    if (!Get.isRegistered<WishlistController>()) {
      Get.put(WishlistController());
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          'Wishlist Saya',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _primaryColor),
          );
        }

        if (controller.wishlistItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Ionicons.heart_dislike_outline,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  "Belum ada produk favorit",
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchWishlist,
          color: _primaryColor,
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.70, // Sedikit lebih tinggi untuk muat tanggal
            ),
            itemCount: controller.wishlistItems.length,
            itemBuilder: (context, index) {
              final doc = controller.wishlistItems[index];
              final data = doc.data() as Map<String, dynamic>;

              return _buildProductCard(doc.id, data);
            },
          ),
        );
      }),
    );
  }

  Widget _buildProductCard(String docId, Map<String, dynamic> data) {
    // 1. Ambil Nama Produk
    String productName = data['product_name'] ?? 'Tanpa Nama';

    // 2. Ambil & Format Tanggal (created_at)
    String dateStr = _formatTimestamp(data['created_at']);

    // 3. Ambil Gambar (Opsional, agar tidak kosong)
    String imageUrl = data['image_url'] ?? '';

    return GestureDetector(
      onTap: () => controller.goToDetail(
        controller.wishlistItems.firstWhere((e) => e.id == docId),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                  // Tombol Hapus
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => controller.removeFromWishlist(docId),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Ionicons.trash_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // INFORMASI PRODUK (NAMA & TANGGAL)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Tanggal Dibuat (Created At)
                  Row(
                    children: [
                      const Icon(
                        Ionicons.time_outline,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  // Harga (Opsional, ambil jika ada)
                  if (data['price'] != null)
                    Text(
                      formatRupiah(data['price']),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: _primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER FORMAT TANGGAL ---
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "-";

    // Jika tipe data dari Firestore adalah Timestamp
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      // Format manual: DD/MM/YYYY HH:MM
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }

    return timestamp.toString();
  }

  // --- HELPER FORMAT RUPIAH ---
  String formatRupiah(dynamic number) {
    if (number == null) return "Rp 0";
    int value = 0;
    if (number is num) {
      value = number.toInt();
    } else {
      value = int.tryParse(number.toString()) ?? 0;
    }
    String str = value.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return "Rp ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}";
  }
}
