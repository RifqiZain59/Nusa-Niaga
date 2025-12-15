// app/modules/detail_promo/bindings/detail_promo_binding.dart
import 'package:get/get.dart';
import '../controllers/detail_promo_controller.dart';

class DetailPromoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailPromoController>(() => DetailPromoController());
  }
}
