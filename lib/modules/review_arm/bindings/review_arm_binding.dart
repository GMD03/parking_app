import 'package:get/get.dart';
import '../controllers/review_arm_controller.dart';

class ReviewArmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewArmController>(() => ReviewArmController());
  }
}