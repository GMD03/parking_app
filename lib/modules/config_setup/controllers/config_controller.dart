import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Added GetStorage import
import '../models/config_model.dart';
import '../../../core/theme/app_colors.dart';
// import '../../../core/routes/app_routes.dart'; // Uncomment if using Routes.LOGIN

class ConfigController extends GetxController {
  // Reactive States
  final syncMode = SyncMode.cloud.obs;
  final apiKeyController = TextEditingController(
    text: "SCADA-8F92-K29M-XQ11-PZLV",
  );

  @override
  void onClose() {
    apiKeyController.dispose();
    super.onClose();
  }

  void updateSyncMode(SyncMode mode) {
    syncMode.value = mode;
  }

  void generateNewKey() {
    // Generates a fake industrial-looking API key
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String segment() =>
        List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();

    apiKeyController.text =
        'SCADA-${segment()}-${segment()}-${segment()}-${segment()}';
  }

  // Changed to Future<void> to allow awaiting the GetStorage write
  Future<void> nextStage() async {
    // 1. Validate API Key
    if (apiKeyController.text.trim().isEmpty) {
      Get.snackbar(
        'CONFIG_ERROR',
        'System API Key cannot be empty.',
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        borderRadius: 2,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // 2. Save configuration state locally
    // This tells the SplashController to skip this page on the next app launch
    final box = GetStorage();
    await box.write('isConfigured', true);

    // 3. Show Success Feedback
    Get.snackbar(
      'SYSTEM_CONFIGURED',
      'Parameters saved. Proceeding to Login portal.',
      backgroundColor: AppColors.success,
      colorText: AppColors.backgroundDark,
      borderRadius: 2,
      margin: const EdgeInsets.all(16),
    );

    // 4. Complete the One-Time Setup by routing to Login
    Get.offAllNamed('/login');
    // Note: Change to Get.offAllNamed(Routes.LOGIN); if you imported app_routes.dart
  }
}
