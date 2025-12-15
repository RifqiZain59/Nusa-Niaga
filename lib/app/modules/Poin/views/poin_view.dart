import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import untuk Ionicons
import 'package:ionicons/ionicons.dart';

// Sesuaikan path controller sesuai dengan proyek Anda
import 'package:nusaniaga/app/modules/Poin/controllers/poin_controller.dart';
// Sesuaikan path ke halaman DetailPoinView Anda
import 'package:nusaniaga/app/modules/detail_poin/views/detail_poin_view.dart';
// Asumsi DetailPoinView ada di folder yang sama. Sesuaikan path ini.

// --- Definisi Model Data ---
class FoodItem {
  final String title;
  final String description;
  final int pointCost;
  final String imagePath;
  final int stock;

  FoodItem({
    required this.title,
    required this.description,
    required this.pointCost,
    required this.imagePath,
    this.stock = 40,
  });
}

// --- Data Dummy ---
final List<FoodItem> dummyFoodItems = [
  FoodItem(
    title: 'Whole Wheat Loaf',
    description: 'Roti utuh bergizi, kaya serat, dan menyehatkan.',
    pointCost: 100,
    imagePath: 'assets/loaf.jpg',
  ),
  FoodItem(
    title: 'Sweet Berry Muffin',
    description: 'Muffin lembut diisi dengan blueberry segar.',
    pointCost: 150,
    imagePath: 'assets/muffin.jpg',
  ),
  FoodItem(
    title: 'Red Velvet Treat',
    description: 'Red velvet lembab dan kaya dengan frosting krim.',
    pointCost: 180,
    imagePath: 'assets/cake.jpg',
  ),
  FoodItem(
    title: 'Banana Pancake',
    description: 'Panekuk lembut dengan irisan pisang manis di dalamnya.',
    pointCost: 80,
    imagePath: 'assets/pancake.jpg',
  ),
  FoodItem(
    title: 'Praline Almond Cake',
    description: 'Paris Brest klasik dengan isian krim praline.',
    pointCost: 120,
    imagePath: 'assets/cake.jpg',
  ),
  FoodItem(
    title: 'Mint Donuts',
    description: 'Dua donat lembut dengan frosting mint manis.',
    pointCost: 75,
    imagePath: 'assets/donut.jpg',
  ),
];
// ---------------------------------------------------

class PoinView extends GetView<PoinController> {
  const PoinView({super.key});

  // =======================================================
  // 1. FUNGSI DIALOG QR CODE (Menampilkan pop-up)
  // =======================================================
  void _showQrCodeDialog() {
    Get.dialog(
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(30.0),
              constraints: const BoxConstraints(maxWidth: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tunjukkan QR Code',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Ionicons.qr_code_outline,
                        size: 180,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Gunakan kode ini untuk menukar poin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierColor: Colors.transparent,
    );
  }

  // =======================================================
  // 2. WIDGET ITEM PENUKARAN POIN BARU (List Item)
  // Termasuk Navigasi ke DetailPoinView
  // =======================================================
  Widget _buildPointRewardItem(FoodItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      // Menggunakan InkWell untuk efek visual yang lebih baik saat ditekan
      child: InkWell(
        onTap: () {
          // Navigasi ke DetailPoinView dan kirim objek FoodItem sebagai argumen
          Get.to(() => DetailPoinView(), arguments: item);
        },
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey.shade200, width: 1.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Item
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  item.imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Icon(
                        Ionicons.image_outline,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),

              // Detail Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Biaya Poin
                    Row(
                      children: [
                        const Icon(
                          Ionicons.star,
                          color: Color(0xFFFFC107), // Warna Emas/Kuning
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.pointCost} Poin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =======================================================
  // 3. WIDGET SEARCH BAR
  // =======================================================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Cari hadiah...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Ionicons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.only(top: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: IconButton(
              icon: const Icon(Ionicons.options, color: Colors.white, size: 24),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // 4. WIDGET KOTAK POIN
  // =======================================================
  Widget _buildPointBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Poin Anda:',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  '1,250 Poin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kedaluwarsa 31 Desember 2025',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
            const Spacer(),
            // Ikon QR yang dapat diklik untuk membuka dialog
            InkWell(
              onTap: _showQrCodeDialog,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(5.0),
                child: const Icon(
                  Ionicons.qr_code_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Header Daftar Item (Judul "Tukar dengan item ini")
  Widget _buildListHeader() {
    return const Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 10.0),
      child: Row(
        children: [
          Text(
            'Tukar dengan item ini:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // 5. WIDGET BUILD UTAMA
  // =======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Konten STATIS (Tidak dapat di-scroll)
            const SizedBox(height: 20),
            _buildSearchBar(),
            _buildPointBox(),
            _buildListHeader(), // Judul sekarang statis
            // Konten DINAMIS (Dapat di-scroll)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 0,
                ),
                itemCount: dummyFoodItems.length,
                itemBuilder: (context, index) {
                  // Tambahkan padding hanya di bagian bawah untuk item terakhir
                  if (index == dummyFoodItems.length - 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: _buildPointRewardItem(dummyFoodItems[index]),
                    );
                  }
                  return _buildPointRewardItem(dummyFoodItems[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
