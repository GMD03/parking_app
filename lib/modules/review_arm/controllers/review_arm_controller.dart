// lib/modules/review_arm/controllers/review_arm_controller.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/aerostatic_dialog.dart';

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

      // GENERATE HARDWARE CONFIG JSON
      final config = ConfigController.getSystemConfig();
      if (config != null) {
        final hardwareJson = {
          "entryIp": config.entryIp,
          "entryPort": config.entryPort,
          "exitIp": config.exitIp,
          "exitPort": config.exitPort,
          "siteName": config.siteName,
        };
        final file = File('hardware_api/hardware_config.json');
        if (!await file.parent.exists()) {
          await file.parent.create(recursive: true);
        }
        await file.writeAsString(jsonEncode(hardwareJson));
        print('Wrote hardware_config.json successfully');
      }

      // Show Success Pop-up
      AerostaticDialog.show(
        title: 'SYSTEM ARMED',
        message: 'Global parking perimeter engaged successfully. Hardware locks are now active.',
        isError: false,
        onAcknowledge: () {
          // Clear navigation stack and go to Dashboard ONLY after acknowledgment
          Get.offAllNamed(Routes.DASHBOARD);
        },
      );
    } catch (e) {
      AerostaticDialog.show(
        title: 'ARMING FAILED',
        message: 'System initialization encountered a fatal error:\n${e.toString()}',
        isError: true,
      );
    } finally {
      // Stop the loading spinner on the button
      isArming.value = false;
    }
  }

  // -----------------------------------------------------------------
  // CUSTOM SYSTEM DIALOG (POP-UP)
  // -----------------------------------------------------------  // Dialog removed
}