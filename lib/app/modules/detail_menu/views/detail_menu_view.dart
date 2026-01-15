import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_menu_controller.dart';

class DetailMenuView extends GetView<DetailMenuController> {
  const DetailMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: Obx(() {
        final p = controller.product;
        if (p.isEmpty)
          return const Center(child: Text("Data produk tidak ditemukan"));

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar Full Width
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Image.network(
                        p['image_url'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama Produk
                          Text(
                            p['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Harga & Stok
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Rp ${p['price']}",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text("Stok: ${p['stock']}"),
                              ),
                            ],
                          ),
                          const Divider(height: 30),

                          // Deskripsi
                          const Text(
                            "Deskripsi:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            p['description'] ?? 'Tidak ada deskripsi.',
                            style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTTOM BAR (ADD TO CART) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Qty Selector
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => controller.decrementQty(),
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          "${controller.quantity.value}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          onPressed: () => controller.incrementQty(),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Button Add
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.addToCart(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blue[800],
                      ),
                      child: const Text(
                        "TAMBAH KE KERANJANG",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
