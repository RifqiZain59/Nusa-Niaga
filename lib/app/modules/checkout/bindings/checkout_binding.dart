// File: ../bindings/checkout_binding.dart

import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    // Controller akan dibuat saat CheckoutView diakses, dan dihapus saat View ditutup.
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
