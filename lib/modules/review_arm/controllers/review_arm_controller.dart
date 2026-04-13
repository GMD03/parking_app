// lib/modules/review_arm/controllers/review_arm_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

// Import our Global Access Helpers
import '../../device_registration/controllers/device_registration_controller.dart';
import '../../config_setup/controllers/config_controller.dart';
import '../../zone_setup/controllers/zone_setup_controller.dart';

class ReviewArmController extends GetxController {
  final isArming = false.obs;
  
  // --- Observables for UI Display ---
  final terminalId = ''.obs;
  final syncMode = ''.obs;
  final apiKeyStatus = ''.obs;
  final totalCapacity = 0.obs;
  final totalZones = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSystemData();
  }

  void _loadSystemData() {
    // 1. Fetch Device Data
    final device = DeviceRegistrationController.getRegisteredDevice();
    terminalId.value = device?.terminalId ?? 'UNKNOWN-TERMINAL';

    // 2. Fetch Config Data
    final config = ConfigController.getSystemConfig();
    syncMode.value = config?.syncMode.name.toUpperCase() ?? 'LOCAL_ONLY';
    apiKeyStatus.value = config?.apiKey.isNotEmpty == true ? 'AUTHENTICATED' : 'UNVERIFIED';

    // 3. Fetch Zone Data
    totalCapacity.value = ZoneSetupController.getTotalCapacity();
    final zones = ZoneSetupController.getConfiguredZones();
    totalZones.value = zones.length;
  }

  void returnToZoneSetup() {
    Get.back();
  }

  Future<void> executeSystemArm() async {
    isArming.value = true;
    
    try {
      // Simulate hardware locking and API handshake
      await Future.delayed(const Duration(seconds: 2)); 

      // ONBOARDING COMPLETE: Lock the system state
      final box = GetStorage();
      await box.write('isConfigured', true);

      // Show Success Pop-up
      _showSystemDialog(
        title: 'SYSTEM ARMED',
        message: 'Global parking perimeter engaged successfully. Hardware locks are now active.',
        isError: false,
        onAcknowledge: () {
          // Clear navigation stack and go to Dashboard ONLY after acknowledgment
          Get.offAllNamed(Routes.DASHBOARD);
        },
      );
    } catch (e) {
      _showSystemDialog(
        title: 'ARMING FAILED',
        message: 'Critical error during hardware handshake: ${e.toString()}',
        isError: true,
      );
    } finally {
      // Stop the loading spinner on the button
      isArming.value = false;
    }
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
          borderRadius: BorderRadius.zero, // Sharp SCADA edges
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
                      style: GoogleFonts.inter(
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
                style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
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