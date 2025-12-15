import 'package:flutter/material.dart';
import 'package:get/get.dart';
// GANTI: Import untuk Ionicons ditambahkan
import 'package:ionicons/ionicons.dart';
import 'package:nusaniaga/app/modules/detail_promo/views/detail_promo_view.dart';

// GANTI: Import DetailPromoController
// ASUMSI LOKASI DETAIL PROMO CONTROLLER!
// Pastikan path import ini benar di proyek Anda.
import 'package:nusaniaga/app/modules/detail_promo/controllers/detail_promo_controller.dart';

// Import Controller yang asli
import '../controllers/promo_controller.dart';

// Definisi Warna Baru (Biru, menggantikan Merah)
const Color primaryBlue = Color(
  0xFF1976D2,
); // Digunakan untuk mengganti 0xFFE53935

// --- Model Data ---
class FoodItem {
  final String name;
  final String description;
  final double originalPrice;
  final int stock;
  final String imageUrl;
  final int discountPercentage;

  FoodItem({
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.stock,
    required this.imageUrl,
    required this.discountPercentage,
  });

  bool get isLowStock => stock <= 10;

  double get discountedPrice {
    return originalPrice * (1 - discountPercentage / 100);
  }
}

// Data Dummy
final List<FoodItem> dummyItems = [
  FoodItem(
    name: 'Whole Wheat Loaf (Diskon 20%)',
    description:
        'Roti Gandum Utuh. Bergizi, kaya serat. Cocok untuk sarapan sehat.',
    originalPrice: 4.50,
    stock: 40,
    imageUrl: 'whole_wheat_loaf.png',
    discountPercentage: 20,
  ),
  FoodItem(
    name: 'Sweet Berry Muffin (Beli 2 Gratis 1)',
    description:
        'Muffin lembut berisi blueberry segar yang juicy. Promo Spesial!',
    originalPrice: 6.50,
    stock: 40,
    imageUrl: 'sweet_berry_muffin.png',
    discountPercentage: 30,
  ),
  FoodItem(
    name: 'Blue Velvet Treat (Harga Spesial)',
    // NOTE: Nama produk "Red Velvet" diubah untuk konsistensi tema
    description:
        'Blue velvet yang kaya dan lembap dengan lapisan krim keju yang lezat.',
    originalPrice: 7.00,
    stock: 40,
    imageUrl: 'blue_velvet_treat.png',
    discountPercentage: 15,
  ),
  FoodItem(
    name: 'Frosted Bliss Donut (Stok Terakhir!)',
    description:
        'Donat biru lembut dengan taburan pelangi cerah. Sisa sedikit!',
    originalPrice: 5.00,
    stock: 10,
    imageUrl: 'frosted_bliss_donut.png',
    discountPercentage: 50,
  ),
];
// ---------------------------------

class PromoView extends GetView<PromoController> {
  const PromoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // 1. --- Header/Area Pencarian dan Filter ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Search Field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari Promo atau Diskon...',
                          border: InputBorder.none,
                          // GANTI: Icons.search -> Ionicons.search
                          prefixIcon: Icon(Ionicons.search, color: Colors.grey),
                          prefixIconConstraints: BoxConstraints(minWidth: 30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter Button
                  Container(
                    decoration: BoxDecoration(
                      color:
                          primaryBlue, // GANTI: Color(0xFFE53935) -> primaryBlue
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      // GANTI: Icons.filter_list -> Ionicons.options
                      icon: const Icon(Ionicons.options, color: Colors.white),
                      onPressed: () {
                        // Aksi tombol filter
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 2. --- KOTAK TAMPILAN BARU: Promo Banner Utama ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _PromoBannerWidget(),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  // Ikon kilat (⚡️) tetap dipertahankan
                  '⚡️ Promo Terpopuler!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 3. --- Daftar Produk/Promo ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                itemCount: dummyItems.length,
                itemBuilder: (context, index) {
                  // MODIFIKASI: Bungkus _PromoListItem dengan GestureDetector/InkWell
                  return InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      // AKSI KLIK: Pindah ke DetailPromoView

                      // **********************************************
                      // PERBAIKAN: Masukkan DetailPromoController sebelum navigasi.
                      // Anda mungkin juga ingin mengirim data 'item' sebagai argumen.
                      // **********************************************
                      if (!Get.isRegistered<DetailPromoController>()) {
                        Get.put(DetailPromoController());
                      }

                      // Opsi yang lebih baik: kirim data sebagai argumen
                      Get.to(
                        () => const DetailPromoView(),
                        arguments:
                            dummyItems[index], // Mengirim data item yang diklik
                      );
                      // **********************************************
                    },
                    child: _PromoListItem(item: dummyItems[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget Promo Banner Unggulan (Warna Merah menjadi Biru) ---
class _PromoBannerWidget extends StatelessWidget {
  const _PromoBannerWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryBlue, // GANTI: Color(0xFFE53935) -> primaryBlue
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(
              0.3,
            ), // GANTI: Colors.red.withOpacity(0.3) -> Colors.blue.withOpacity(0.3)
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'DISKON BESAR!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Semua produk roti diskon hingga 50%. Berlaku hari ini saja!',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget Kustom untuk Setiap Item Daftar (Warna Merah menjadi Biru) ---
class _PromoListItem extends StatelessWidget {
  final FoodItem item;

  const _PromoListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    Color stockColor;
    String stockText;

    if (item.isLowStock) {
      stockColor = Colors.orange[100]!;
      stockText = 'Stok Sisa: ${item.stock}';
    } else {
      stockColor = Colors.green[100]!;
      stockText = 'Stok Tersedia: ${item.stock}';
    }

    // CATATAN: Margin dipindahkan ke InkWell di ListView.builder
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        item.imageUrl.split('.').first,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  // Badge Diskon (Overlay di Pojok Kanan Atas)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color:
                            primaryBlue, // GANTI: Color(0xFFE53935) -> primaryBlue
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        '-${item.discountPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Detail Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Produk
                    Flexible(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              primaryBlue, // GANTI: Color(0xFFE53935) -> primaryBlue
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Stok (Badge)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: stockColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        stockText,
                        style: TextStyle(
                          color: item.isLowStock
                              ? Colors.orange[800]
                              : Colors.green[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Deskripsi Produk
                Text(
                  item.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Area Harga
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Harga Asli (Dicoret)
                        Text(
                          '\$${item.originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        // Harga Diskon
                        Text(
                          '\$${item.discountedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color:
                                primaryBlue, // GANTI: Color(0xFFE53935) -> primaryBlue
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
