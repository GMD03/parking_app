import 'package:get/get.dart';
import 'app_routes.dart';
import '../../modules/login/views/login_view.dart';
import '../../modules/login/bindings/login_binding.dart';
import '../../modules/device_registration/views/device_registration_view.dart';
import '../../modules/device_registration/bindings/device_registration_binding.dart';
import '../../modules/config_setup/views/config_view.dart';
import '../../modules/config_setup/bindings/config_binding.dart';
import '../../modules/zone_setup/views/zone_setup_view.dart';
import '../../modules/zone_setup/bindings/zone_setup_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/dashboard/views/dashboard_view.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/review_arm/views/review_arm_view.dart';
import '../../modules/review_arm/bindings/review_arm_binding.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.SPLASH, page: () => const SplashView()),
    GetPage(
      name: Routes.DEVICE_REGISTRATION,
      page: () => const DeviceRegistrationView(),
      binding: DeviceRegistrationBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.CONFIG_SETUP,
      page: () => const ConfigView(),
      binding: ConfigBinding(),
    ),
    GetPage(
      name: Routes.ZONE_SETUP,
      page: () => const ZoneSetupView(),
      binding: ZoneSetupBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.REVIEW_ARM,
      page: () => const ReviewArmView(),
      binding: ReviewArmBinding(),
    ),
  ];
}