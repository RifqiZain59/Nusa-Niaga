import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Import Controller yang diperlukan
import '../controllers/detail_menu_controller.dart';

// Import View Tujuan (SESUAIKAN PATH INI DENGAN STRUKTUR PROYEK ANDA)
import '../../checkout/views/checkout_view.dart';
// Asumsi Anda juga memiliki file rute terpusat (contoh: AppPages)

class DetailMenuView extends GetView<DetailMenuController> {
  // Tambahkan parameter untuk menerima data menu yang diklik dari HomeView
  final Map<String, dynamic>? item;

  const DetailMenuView({super.key, this.item});

  // Deklarasi System Overlay Style untuk ikon hitam pada status bar terang/transparan
  static const SystemUiOverlayStyle _darkStatusBar = SystemUiOverlayStyle(
    statusBarIconBrightness:
        Brightness.dark, // Ikon status bar menjadi gelap (hitam)
    statusBarColor: Colors.transparent, // Warna status bar tetap transparan
  );

  @override
  Widget build(BuildContext context) {
    // Definisikan data yang akan digunakan (mengambil dari item jika ada, jika tidak, gunakan default)
    final String menuName = item?['name'] ?? 'Caffe Mocha';
    final double menuPrice = item?['price'] ?? 4.53;
    final double menuRating = item?['rating'] ?? 4.8;
    final String menuImage = item?['image'] ?? 'assets/caffe_mocha.jpg';
    final String menuType = item?['type'] ?? 'Ice/Hot';

    // Definisi warna dan padding
    const Color primaryColor = Color(0xFF6E4E3A); // Cokelat tua
    const Color buttonColor = Color(0xFFC78C53); // Cokelat oranye/aksen
    const double horizontalPadding = 20.0;
    const double borderRadius = 12.0;

    // Inisialisasi controller jika belum terdaftar (optional, tergantung binding Anda)
    // Jika Anda menggunakan Get.put() di binding, baris ini tidak diperlukan.
    if (Get.isRegistered<DetailMenuController>() == false) {
      Get.put(DetailMenuController());
    }

    // --- Widget Kustom Pengontrol Kuantitas (Menggunakan Obx untuk reaktif) ---
    Widget _buildQuantityControl() {
      return Obx(() {
        final int currentQuantity = controller
            .quantity
            .value; // Mengambil nilai reaktif dari controller

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Kurang (-)
              InkWell(
                onTap: () {
                  controller
                      .decrementQuantity(); // Memanggil fungsi di controller
                },
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.remove, color: primaryColor, size: 24),
                ),
              ),
              const SizedBox(width: 16),

              // Angka Kuantitas Reaktif
              Text(
                currentQuantity.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 16),

              // Tombol Tambah (+)
              InkWell(
                onTap: () {
                  controller
                      .incrementQuantity(); // Memanggil fungsi di controller
                },
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        );
      });
    }

    // --- Struktur Utama Halaman ---
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar Kustom
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: _darkStatusBar,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Detail Menu',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              // Logika toggle favorit
            },
          ),
        ],
      ),

      // Isi Halaman
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Menu
            Padding(
              padding: const EdgeInsets.all(horizontalPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius * 2),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.asset(
                    menuImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Padding untuk konten di bawah gambar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Nama Minuman
                  Text(
                    menuName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 3. Tipe dan Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        menuType,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      // Rating Bintang
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            menuRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            ' (230)',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 4. Judul Deskripsi
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 5. Teks Deskripsi (Simulasi Teks dan "Read More")
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      children: <TextSpan>[
                        const TextSpan(
                          text:
                              'A cappuccino is an approximately 150 ml (5 oz) beverage, with 25 ml of espresso coffee and 85ml of fresh milk the fo.. ',
                        ),
                        TextSpan(
                          text: 'Read More',
                          style: TextStyle(
                            color: buttonColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. Kontrol Kuantitas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      _buildQuantityControl(), // Widget kontrol kuantitas reaktif
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 7. INPUTAN CATATAN (SPECIAL INSTRUCTIONS)
                  const Text(
                    'Special Instructions/Notes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: controller
                        .notesTextController, // Menambahkan controller
                    decoration: InputDecoration(
                      hintText:
                          'Misalnya: Ekstra gula, tanpa es, atau pesan khusus...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: const BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                  ),

                  const SizedBox(height: 12),

                  // Ruang di bawah konten sebelum bottomNavigationBar muncul
                  SizedBox(height: Get.height * 0.15),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bagian Bawah: Harga dan Tombol Beli (Bottom Navigation Bar)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Harga
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Obx(
                      () => Text(
                        '\$ ${controller.totalPrice.value.toStringAsFixed(2)}', // Harga reaktif
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Tombol "Buy Now"
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    // 1. Kumpulkan data pesanan
                    final Map<String, dynamic> orderData = {
                      'name': menuName,
                      'price_per_item': menuPrice,
                      'quantity': controller.quantity.value,
                      'total_amount': controller.totalPrice.value,
                      'notes': controller.notesTextController.text,
                    };

                    // 2. Navigasi ke CheckoutView dan kirim data
                    Get.to(() => const CheckoutView(), arguments: orderData);

                    // Atau, jika Anda menggunakan rute terpusat:
                    // Get.toNamed(Routes.CHECKOUT, arguments: orderData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
