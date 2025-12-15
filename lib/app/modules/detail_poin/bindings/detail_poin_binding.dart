import 'package:get/get.dart';

import '../controllers/detail_poin_controller.dart';

class DetailPoinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailPoinController>(
      () => DetailPoinController(),
    );
  }
}
