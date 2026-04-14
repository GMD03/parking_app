// lib/modules/login/controllers/login_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/database_service.dart'; 
import 'package:google_fonts/google_fonts.dart'; 
import '../models/user_model.dart';
// We import the Device Registration controller to access its static helper
import '../../device_registration/controllers/device_registration_controller.dart'; 
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart'; 
import '../../../core/widgets/aerostatic_dialog.dart'; 

class LoginController extends GetxController {
  final operatorIdController = TextEditingController();
  final passcodeController = TextEditingController();

  final isLoading = false.obs;
  final nodeStatus = 'NODE_ONLINE'.obs;
  final isStatusSuccess = true.obs;
  final isPasswordObscured = true.obs;

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  // --- Storage Key Constant ---
  static const String _sessionKey = 'currentUserSession';

  @override
  void onClose() {
    operatorIdController.dispose();
    passcodeController.dispose();
    super.onClose();
  }

  Future<void> authenticate() async {
    if (isLoading.value) return;

    final operatorId = operatorIdController.text.trim();
    final passcode = passcodeController.text;

    if (operatorId.isEmpty || passcode.isEmpty) {
      AerostaticDialog.show(
        title: 'ACCESS DENIED', 
        message: 'Missing credentials. Please provide Operator ID and Passcode.', 
        isError: true
      );
      return;
    }

    isLoading.value = true;
    nodeStatus.value = 'AUTHENTICATING...';
    isStatusSuccess.value = true;

    await Future.delayed(const Duration(seconds: 2)); 

    // Keeping your requested current credentials
    if (operatorId == 'ADMIN_01' && passcode == '12345678') {
      
      // 1. Fetch the REAL terminal ID from the device registration storage!
      final registeredDevice = DeviceRegistrationController.getRegisteredDevice();
      final actualTerminalId = registeredDevice?.terminalId ?? 'UNKNOWN-TERMINAL';

      final user = UserModel(
        operatorId: operatorId,
        terminalId: actualTerminalId, // Using the real data!
        token: 'AUTH-${DateTime.now().millisecondsSinceEpoch}', // Pseudo-dynamic token
      );

      nodeStatus.value = 'ACCESS_GRANTED';

      // 2. PERSISTENCE: Save the active user session
      await DatabaseService.saveState(_sessionKey, user.toJson());

      bool isConfigured = DatabaseService.getState('isConfigured') ?? false;

      if (!isConfigured) {
        // First-time setup flow
        Get.offAllNamed(Routes.CONFIG_SETUP);
      } else {
        // App is configured, proceed to dashboard
        AerostaticDialog.show(
          title: 'ACCESS GRANTED',
          message: 'Authentication verified for $actualTerminalId. Routing to Main Dashboard...',
          isError: false,
          onAcknowledge: () {
            Get.offAllNamed(Routes.DASHBOARD);
          }
        );
      }
    } else {
      AerostaticDialog.show(
        title: 'AUTH FAILED', 
        message: 'Invalid Operator ID or Passcode.', 
        isError: true
      );
      nodeStatus.value = 'NODE_ONLINE';
      isStatusSuccess.value = false;
    }

    isLoading.value = false;
  }

  // --- GLOBAL ACCESS HELPER ---
  // The Dashboard can now call LoginController.getCurrentUser() to show the Operator ID
  static UserModel? getCurrentUser() {
    final data = DatabaseService.getState(_sessionKey);
    if (data != null) {
      return UserModel.fromJson(data);
    }
    return null;
  }

  // Dialog removed
}