import 'package:get/get.dart';

class DetailMenuController extends GetxController {
  // Menyimpan data produk yang diterima dari argument navigasi
  var product = <String, dynamic>{}.obs;
  var quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil arguments yang dikirim dari HomeView
    if (Get.arguments != null) {
      product.value = Get.arguments;
    }
  }

  void incrementQty() {
    // Cek stok (convert ke int dulu)
    int stock = int.tryParse(product['stock'].toString()) ?? 0;
    if (quantity.value < stock) {
      quantity.value++;
    } else {
      Get.snackbar("Info", "Stok maksimal tercapai");
    }
  }

  void decrementQty() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void addToCart() {
    // Logika tambah ke keranjang bisa ditambahkan di sini
    // Misalnya simpan ke LocalStorage atau CartController global
    Get.snackbar(
      "Sukses",
      "${quantity.value}x ${product['name']} masuk keranjang!",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
