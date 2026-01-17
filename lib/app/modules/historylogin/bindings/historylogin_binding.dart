import 'package:get/get.dart';

import '../controllers/historylogin_controller.dart';

class HistoryloginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryloginController>(
      () => HistoryloginController(),
    );
  }
}
