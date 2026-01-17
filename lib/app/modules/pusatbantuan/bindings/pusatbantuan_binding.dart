import 'package:get/get.dart';

import '../controllers/pusatbantuan_controller.dart';

class PusatbantuanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PusatbantuanController>(
      () => PusatbantuanController(),
    );
  }
}
