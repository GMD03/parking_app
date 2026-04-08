import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/routes/app_routes.dart'; // Adjust path if needed

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _checkAppSetupState();
  }

  void _checkAppSetupState() async {
    // Add a small delay for visual effect (optional)
    await Future.delayed(const Duration(seconds: 2));

    final box = GetStorage();

    // Read stored values (defaults to false if null)
    bool isRegistered = box.read('isDeviceRegistered') ?? false;
    bool isConfigured = box.read('isConfigured') ?? false;

    // Routing Logic
    if (!isRegistered) {
      Get.offAllNamed(Routes.DEVICE_REGISTRATION);
    } else if (!isConfigured) {
      Get.offAllNamed(Routes.CONFIG_SETUP);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
