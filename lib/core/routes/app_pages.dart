import 'package:get/get.dart';
import '../../modules/login/views/login_view.dart';
import '../../modules/login/bindings/login_binding.dart';
import '../../modules/device_registration/views/device_registration_view.dart';
import '../../modules/device_registration/bindings/device_registration_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.DEVICE_REGISTRATION,
      page: () => const DeviceRegistrationView(),
      binding: DeviceRegistrationBinding(),
    ),
  ];
}
