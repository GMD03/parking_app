// lib/modules/config_setup/controllers/config_controller.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../models/config_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/aerostatic_dialog.dart';

class ConfigController extends GetxController {
  final syncMode = SyncMode.cloud.obs;
  final apiKeyController = TextEditingController(
    text: "SCADA-8F92-K29M-XQ11-PZLV",
  );

  // --- Storage Key Constant ---
  static const String _storageKey = 'systemConfiguration';

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

  Future<void> nextStage() async {
    // 1. Validation
    if (apiKeyController.text.trim().isEmpty) {
      AerostaticDialog.show(
        title: 'CONFIG ERROR',
        message: 'System API Key cannot be empty. Please generate or input a valid key to proceed.',
        isError: true,
      );
      return;
    }

    // 2. Package data into the model
    final configData = ConfigModel(
      syncMode: syncMode.value,
      apiKey: apiKeyController.text.trim(),
    );

    // 3. PERSISTENCE: Save to GetStorage
    final box = GetStorage();
    await box.write(_storageKey, configData.toJson());

    // 4. Route to next onboarding step
    Get.toNamed(Routes.ZONE_SETUP);
  }

  // --- GLOBAL ACCESS HELPER ---
  // Any service in the app can call ConfigController.getSystemConfig()
  // to check if the app should be syncing to the cloud or staying local.
  static ConfigModel? getSystemConfig() {
    final box = GetStorage();
    final data = box.read(_storageKey);
    if (data != null) {
      return ConfigModel.fromJson(data);
    }
    return null;
  }

  // Dialog removed
}