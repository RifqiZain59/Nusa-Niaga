import 'package:get/get.dart';

import '../controllers/detailpesanansaya_controller.dart';

class DetailpesanansayaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailpesanansayaController>(
      () => DetailpesanansayaController(),
    );
  }
}
