import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/config_model.dart';
import '../../../core/theme/app_colors.dart';

class ConfigController extends GetxController {
  // Reactive States
  final syncMode = SyncMode.cloud.obs;
  final apiKeyController = TextEditingController(text: "SCADA-8F92-K29M-XQ11-PZLV");

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
    String segment() => List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    
    apiKeyController.text = 'SCADA-${segment()}-${segment()}-${segment()}-${segment()}';
  }

  void nextStage() {
    // Validate and proceed to Zone Setup
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
    
    // TODO: Route to Zone Setup
    // Get.toNamed('/zone_setup');
    Get.snackbar(
      'SYSTEM_CONFIGURED', 
      'Parameters saved. Proceeding to Zone Setup.',
      backgroundColor: AppColors.success,
      colorText: AppColors.backgroundDark,
      borderRadius: 2,
      margin: const EdgeInsets.all(16),
    );
  }
}