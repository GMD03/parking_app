import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class ReviewArmController extends GetxController {
  final isArming = false.obs;
  
  // You can load these from GetStorage if needed
  final totalCapacity = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final box = GetStorage();
    totalCapacity.value = box.read('totalFacilityCapacity') ?? 0;
  }

  void returnToZoneSetup() {
    Get.back();
  }

  Future<void> executeSystemArm() async {
    isArming.value = true;
    
    // Simulate hardware locking and API handshake
    await Future.delayed(const Duration(seconds: 2)); 

    // ONBOARDING COMPLETE: Save state globally
    final box = GetStorage();
    await box.write('isConfigured', true);

    Get.snackbar(
      'SYSTEM_ARMED',
      'Global parking perimeter engaged successfully.',
      backgroundColor: AppColors.success,
      colorText: AppColors.backgroundDark,
      borderRadius: 0,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle_outline, color: AppColors.backgroundDark),
    );
    
    // Clear navigation stack and go to Dashboard
    Get.offAllNamed(Routes.DASHBOARD);
  }
}