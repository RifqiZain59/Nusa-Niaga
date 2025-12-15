import 'package:get/get.dart';

import '../controllers/detail_menu_controller.dart';

class DetailMenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailMenuController>(
      () => DetailMenuController(),
    );
  }
}
