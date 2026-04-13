import 'package:get/get.dart';
import '../../../core/services/database_service.dart';
import '../../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _checkAppSetupState();
  }

  void _checkAppSetupState() async {
    await Future.delayed(const Duration(seconds: 2));

    bool isRegistered = DatabaseService.getState('isDeviceRegistered') ?? false;

    // Routing Logic: Hardware registration is pre-login. 
    // Configuration check happens POST-login.
    if (!isRegistered) {
      Get.offAllNamed(Routes.DEVICE_REGISTRATION);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}