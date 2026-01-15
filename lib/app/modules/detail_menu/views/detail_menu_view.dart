import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/detail_menu_controller.dart';
import '../../checkout/views/checkout_view.dart';

class DetailMenuView extends GetView<DetailMenuController> {
  const DetailMenuView({super.key});

  String formatRibuan(double number) {
    String str = number.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA BIRU MODERN ---
    const Color kPrimaryColor = Color(0xFF0D47A1);
    const Color kSecondaryColor = Color(0xFF42A5F5);
    const Color kBackgroundColor = Color(0xFFF5F7FA);
    const Color kGoldColor = Color(0xFFFFC107);

    // State untuk Rating
    final RxInt userRatingInput = 5.obs;

    if (!Get.isRegistered<DetailMenuController>()) {
      Get.put(DetailMenuController());
    }

    // --- SYSTEM UI NAV BAR PUTIH ---
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Obx(() {
          if (controller.isLoading.value && controller.product.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          final product = controller.product;
          final String img = product['image_url'] ?? '';

          // Logika Cek Deskripsi
          String description = product['description'] ?? '';
          if (description.trim().isEmpty) {
            description = "Belum ada deskripsi detail untuk menu ini.";
          }

          return Stack(
            children: [
              // 1. GAMBAR BACKGROUND
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 350,
                child: img.isNotEmpty
                    ? Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            Container(color: Colors.grey[300]),
                      )
                    : Container(color: Colors.grey[300]),
              ),

              // 2. TOMBOL BACK & FAVORITE
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.toggleFavorite(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            controller.isFavorite.value
                                ? Ionicons.heart
                                : Ionicons.heart_outline,
                            color: controller.isFavorite.value
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. KONTEN SCROLLABLE
              Positioned.fill(
                top: 300,
                child: Container(
                  decoration: const BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.zero,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 250),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Nama & Kategori
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? 'Nama Menu',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2D2D2D),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    product['category'] ?? 'General',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: kGoldColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    product['rating']?.toString() ?? '4.5',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Quantity Control
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Jumlah Pesanan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildQuantityControl(controller, kPrimaryColor),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // --- DESKRIPSI DENGAN KOTAK ---
                        const Text(
                          "Deskripsi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          // Menampilkan deskripsi atau placeholder jika kosong
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              // Ubah warna text jadi abu-abu jika itu text default/kosong
                              color:
                                  (product['description'] == null ||
                                      product['description'] == '')
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                              height: 1.6,
                              fontStyle:
                                  (product['description'] == null ||
                                      product['description'] == '')
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. FLOATING BOTTOM DOCK
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 20,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // BUTTON TRIGGER ULASAN
                      GestureDetector(
                        onTap: () {
                          _showRatingBottomSheet(
                            context,
                            userRatingInput,
                            kGoldColor,
                            kPrimaryColor,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: kBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Ionicons.create_outline,
                                size: 18,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Tulis Ulasan",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Obx(
                                () => Row(
                                  children: List.generate(
                                    userRatingInput.value,
                                    (index) => const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: kGoldColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // CHECKOUT BAR
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Total Harga",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    "Rp ${formatRibuan(controller.totalPrice.value)}",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Get.to(
                                () => const CheckoutView(),
                                arguments: {
                                  ...controller.product,
                                  'quantity': controller.quantity.value,
                                  'total': controller.totalPrice.value,
                                  'user_rating': userRatingInput.value,
                                },
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Beli Sekarang",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // --- POP UP INPUT RATING (BOTTOM SHEET) ---
  void _showRatingBottomSheet(
    BuildContext context,
    RxInt ratingObs,
    Color goldColor,
    Color primaryColor,
  ) {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Bagaimana pesananmu?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Berikan rating untuk menu ini",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),

            // BINTANG
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      ratingObs.value = index + 1;
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: AnimatedScale(
                        scale: index < ratingObs.value ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          index < ratingObs.value
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: goldColor,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 30),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    "Terima Kasih!",
                    "Rating ${ratingObs.value} bintang tersimpan.",
                    backgroundColor: primaryColor,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(20),
                    borderRadius: 10,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Simpan Ulasan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildQuantityControl(DetailMenuController controller, Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        children: [
          _squareBtn(
            icon: Icons.remove,
            color: Colors.grey.shade100,
            iconColor: Colors.black,
            onTap: controller.decrementQuantity,
          ),
          SizedBox(
            width: 50,
            child: Center(
              child: Obx(
                () => Text(
                  '${controller.quantity.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          _squareBtn(
            icon: Icons.add,
            color: primary,
            iconColor: Colors.white,
            onTap: controller.incrementQuantity,
          ),
        ],
      ),
    );
  }

  Widget _squareBtn({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}
