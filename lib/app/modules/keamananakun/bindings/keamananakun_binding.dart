import 'package:get/get.dart';

import '../controllers/keamananakun_controller.dart';

class KeamananakunBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KeamananakunController>(
      () => KeamananakunController(),
    );
  }
}
