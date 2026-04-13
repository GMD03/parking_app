// lib/modules/config_setup/controllers/config_controller.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/database_service.dart';
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

  final entryIpCtrl = TextEditingController(text: "192.168.8.230");
  final entryPortCtrl = TextEditingController(text: "8008");
  final exitIpCtrl = TextEditingController(text: "192.168.8.231");
  final exitPortCtrl = TextEditingController(text: "8009");
  final siteNameCtrl = TextEditingController(text: "LA SALLE");

  // --- Storage Key Constant ---
  static const String _storageKey = 'systemConfiguration';

  @override
  void onInit() {
    super.onInit();
    final saved = getSystemConfig();
    if (saved != null) {
      syncMode.value = saved.syncMode;
      apiKeyController.text = saved.apiKey;
      entryIpCtrl.text = saved.entryIp;
      entryPortCtrl.text = saved.entryPort.toString();
      exitIpCtrl.text = saved.exitIp;
      exitPortCtrl.text = saved.exitPort.toString();
      siteNameCtrl.text = saved.siteName;
    }
  }

  @override
  void onClose() {
    apiKeyController.dispose();
    entryIpCtrl.dispose();
    entryPortCtrl.dispose();
    exitIpCtrl.dispose();
    exitPortCtrl.dispose();
    siteNameCtrl.dispose();
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
    if (syncMode.value == SyncMode.cloud && apiKeyController.text.trim().isEmpty) {
      AerostaticDialog.show(
        title: 'CONFIG ERROR',
        message: 'System API Key cannot be empty when Cloud Sync is enabled.',
        isError: true,
      );
      return;
    }

    if (entryIpCtrl.text.trim().isEmpty || exitIpCtrl.text.trim().isEmpty) {
      AerostaticDialog.show(
        title: 'CONFIG ERROR',
        message: 'Hardware IP mappings cannot be empty.',
        isError: true,
      );
      return;
    }

    // 2. Package data into the model
    final configData = ConfigModel(
      syncMode: syncMode.value,
      apiKey: apiKeyController.text.trim(),
      entryIp: entryIpCtrl.text.trim(),
      entryPort: int.tryParse(entryPortCtrl.text.trim()) ?? 8008,
      exitIp: exitIpCtrl.text.trim(),
      exitPort: int.tryParse(exitPortCtrl.text.trim()) ?? 8009,
      siteName: siteNameCtrl.text.trim(),
    );

    // 3. PERSISTENCE: Save to DatabaseService
    await DatabaseService.saveState(_storageKey, configData.toJson());

    // 4. Route to next onboarding step
    Get.toNamed(Routes.ZONE_SETUP);
  }

  // --- GLOBAL ACCESS HELPER ---
  // Any service in the app can call ConfigController.getSystemConfig()
  // to check if the app should be syncing to the cloud or staying local.
  static ConfigModel? getSystemConfig() {
    final data = DatabaseService.getState(_storageKey);
    if (data != null) {
      return ConfigModel.fromJson(data);
    }
    return null;
  }

  // Dialog removed
}