// lib/modules/device_registration/bindings/device_registration_binding.dart

import 'package:get/get.dart';
import '../controllers/device_registration_controller.dart';

class DeviceRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeviceRegistrationController>(
      () => DeviceRegistrationController(),
    );
  }
}