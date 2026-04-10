// lib/modules/config_setup/controllers/config_controller.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../models/config_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';

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
      _showSystemDialog(
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

  // -----------------------------------------------------------------
  // CUSTOM SYSTEM DIALOG (POP-UP)
  // -----------------------------------------------------------------
  void _showSystemDialog({
    required String title,
    required String message,
    required bool isError,
    VoidCallback? onAcknowledge,
  }) {
    final Color bgColor = AppColors.surface; 
    final Color borderColor = isError ? AppColors.danger : AppColors.success;
    final Color textColor = isError ? Colors.white : AppColors.backgroundDark;

    Get.dialog(
      Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, 
          side: BorderSide(color: borderColor.withOpacity(0.5), width: 2),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: borderColor,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.ibmPlexSans(
                        color: borderColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.ibmPlexMono(
                  color: AppColors.textMain,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); 
                    if (onAcknowledge != null) {
                      onAcknowledge(); 
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: borderColor,
                    foregroundColor: textColor,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: Text(
                    '[ ACKNOWLEDGE ]',
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, 
    );
  }
}