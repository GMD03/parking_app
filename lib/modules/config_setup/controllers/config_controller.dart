import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// GetStorage removed from here as we save state in Zone Setup instead
import '../models/config_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';

class ConfigController extends GetxController {
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
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String segment() => List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    apiKeyController.text = 'SCADA-${segment()}-${segment()}-${segment()}-${segment()}';
  }

  void nextStage() {
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

    // Move to the next onboarding step (Do not set isConfigured true yet)
    Get.toNamed(Routes.ZONE_SETUP);
  }
}