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
    // --- KONFIGURASI WARNA ---
    const Color kPrimaryColor = Color(0xFF0D47A1);
    const Color kBackgroundColor = Color(0xFFF5F7FA);
    const Color kGoldColor = Color(0xFFFFC107);

    // --- INISIALISASI CONTROLLER ---
    if (!Get.isRegistered<DetailMenuController>()) {
      Get.put(DetailMenuController());
    }

    if (Get.arguments != null && controller.product.isEmpty) {
      if (Get.arguments is Map<String, dynamic>) {
        controller.product.assignAll(Get.arguments);
        if (controller.totalPrice.value == 0) {
          double price =
              double.tryParse(controller.product['price'].toString()) ?? 0.0;
          controller.totalPrice.value = price;
          controller.quantity.value = 1;
        }
      }
    }

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
          final String img = product['image_url'] ?? product['image'] ?? '';
          final String category =
              product['category'] ?? product['type'] ?? 'Menu';
          final String name = product['name'] ?? 'Tanpa Nama';

          String rawDesc = product['description']?.toString() ?? '';
          String description = rawDesc;
          bool isDescEmpty = false;

          if (rawDesc.trim().isEmpty ||
              rawDesc.toLowerCase() == 'null' ||
              rawDesc == '-') {
            description = "Belum ada deskripsi detail untuk menu ini.";
            isDescEmpty = true;
          }

          double ratingDouble =
              double.tryParse(product['rating'].toString()) ?? 0.0;
          String ratingDisplay = ratingDouble == 0
              ? "Baru"
              : ratingDouble.toStringAsFixed(1);

          return Stack(
            children: [
              // 1. GAMBAR BACKGROUND
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 350,
                child: Container(
                  color: Colors.grey[200],
                  child: (img.isNotEmpty && img.startsWith('http'))
                      ? Image.network(
                          img,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              Container(color: Colors.grey[300]),
                        )
                      : (img.isNotEmpty
                            ? Image.asset(img, fit: BoxFit.cover)
                            : Container()),
                ),
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
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
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
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 8),
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

              // 3. KONTEN
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
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 150),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2D2D2D),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryColor,
                                      ),
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
                                    ratingDisplay,
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
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDescEmpty
                                  ? Colors.grey[400]
                                  : Colors.grey[800],
                              height: 1.6,
                              fontStyle: isDescEmpty
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

              // 4. BOTTOM DOCK
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.to(
                            () => const CheckoutView(),
                            arguments: {
                              ...controller.product,
                              'quantity': controller.quantity.value,
                              'total_price': controller.totalPrice.value,
                            },
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildQuantityControl(DetailMenuController controller, Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _squareBtn(Icons.remove, () => controller.decrementQuantity()),
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
            Icons.add,
            () => controller.incrementQuantity(),
            color: primary,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _squareBtn(
    IconData icon,
    VoidCallback onTap, {
    Color? color,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: iconColor ?? Colors.black, size: 18),
      ),
    );
  }
}
