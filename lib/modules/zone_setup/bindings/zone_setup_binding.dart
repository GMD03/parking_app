import 'package:get/get.dart';
import '../controllers/zone_setup_controller.dart';

class ZoneSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZoneSetupController>(() => ZoneSetupController());
  }
}