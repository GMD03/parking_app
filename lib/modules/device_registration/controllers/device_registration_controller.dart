// lib/modules/device_registration/controllers/device_registration_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/device_registration_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart'; 
import '../../../core/widgets/aerostatic_dialog.dart';

class DeviceRegistrationController extends GetxController {
  // --- Observables for UI State ---
  final terminalId = '8842-X-ALPHA'.obs;
  final isTokenObscured = true.obs;
  final isRegistering = false.obs;

  // --- Text Controllers ---
  final facilityCodeController = TextEditingController();
  final securityTokenController = TextEditingController();

  // --- Storage Key Constant ---
  // Using a constant prevents typo bugs when saving/reading from other files
  static const String _storageKey = 'deviceRegistrationData';

  void toggleTokenVisibility() {
    isTokenObscured.value = !isTokenObscured.value;
  }

  // --- Core Registration Logic ---
  Future<void> registerTerminal() async {
    // 1. Validation
    if (facilityCodeController.text.trim().isEmpty ||
        securityTokenController.text.trim().isEmpty) {
      AerostaticDialog.show(
        title: 'VALIDATION ERROR',
        message: 'Facility Code and Security Token are required to proceed.',
        isError: true,
      );
      return;
    }

    isRegistering.value = true;

    try {
      // 2. Create the Model instance
      final registrationData = DeviceRegistrationModel(
        terminalId: terminalId.value,
        facilityCode: facilityCodeController.text.trim(),
        securityToken: securityTokenController.text.trim(),
      );

      // 3. Simulate API Call
      print('Sending Payload: ${registrationData.toJson()}');
      await Future.delayed(const Duration(seconds: 2));

      // 4. PERSISTENCE: Save the data locally
      await DatabaseService.saveState('isDeviceRegistered', true);
      await DatabaseService.saveState(_storageKey, registrationData.toJson());

      // 5. Success Handling & Navigation
      AerostaticDialog.show(
        title: 'SYSTEM REGISTERED',
        message: 'Terminal has been authenticated and registered successfully on the local network.',
        isError: false,
        onAcknowledge: () {
          Get.offAllNamed(Routes.LOGIN);
        },
      );
    } catch (e) {
      AerostaticDialog.show(
        title: 'REGISTRATION FAILED',
        message: 'An error occurred during authentication: ${e.toString()}',
        isError: true,
      );
    } finally {
      isRegistering.value = false;
    }
  }

  // --- GLOBAL ACCESS HELPER ---
  // Any controller in the app can call DeviceRegistrationController.getRegisteredDevice()
  // to get the persisted data without needing to inject this controller.
  static DeviceRegistrationModel? getRegisteredDevice() {
    final data = DatabaseService.getState(_storageKey);
    if (data != null) {
      return DeviceRegistrationModel.fromJson(data);
    }
    return null; // Returns null if the device hasn't been registered yet
  }

  @override
  void onClose() {
    facilityCodeController.dispose();
    securityTokenController.dispose();
    super.onClose();
  }

  // Dialog removed
}