import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailMenuController extends GetxController {
  // State reaktif untuk kuantitas
  RxInt quantity = 1.obs;
  // State reaktif untuk harga total
  RxDouble totalPrice =
      4.53.obs; // Harga awal (sesuaikan dengan harga item default)

  // Controller untuk input catatan
  final TextEditingController notesTextController = TextEditingController();

  // Harga dasar item (harus diinisialisasi berdasarkan item yang diklik)
  // Untuk demo, kita gunakan harga default 4.53.
  final double itemPrice = 4.53;

  @override
  void onInit() {
    super.onInit();

    // Hitung ulang total harga setiap kali kuantitas berubah
    ever(quantity, (_) => _updateTotalPrice());
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void _updateTotalPrice() {
    totalPrice.value = itemPrice * quantity.value;
  }

  @override
  void onClose() {
    notesTextController.dispose();
    super.onClose();
  }
}
