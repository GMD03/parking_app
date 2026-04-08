import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Required to check setup status
import '../models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart'; // Added Routes import

class LoginController extends GetxController {
  // UI Controls
  final operatorIdController = TextEditingController();
  final passcodeController = TextEditingController();

  // Reactive State Variables (The .obs makes them observable)
  final isLoading = false.obs;
  final nodeStatus = 'NODE_ONLINE'.obs;
  final isStatusSuccess = true.obs;

  @override
  void onClose() {
    operatorIdController.dispose();
    passcodeController.dispose();
    super.onClose();
  }

  // Business Logic
  Future<void> authenticate() async {
    final operatorId = operatorIdController.text.trim();
    final passcode = passcodeController.text;

    // Simple Validation
    if (operatorId.isEmpty || passcode.isEmpty) {
      _showSystemAlert('ACCESS_DENIED', 'Missing credentials.');
      return;
    }

    // Simulate Network Request
    isLoading.value = true;
    nodeStatus.value = 'AUTHENTICATING...';
    isStatusSuccess.value = true;

    await Future.delayed(const Duration(seconds: 2)); // Fake API delay

    // Dummy Auth Check
    if (operatorId == 'ADMIN_01' && passcode == '12345678') {
      // Create Model instance
      final user = UserModel(
        operatorId: operatorId,
        terminalId: 'LCL-4A',
        token: 'xyz123',
      );

      nodeStatus.value = 'ACCESS_GRANTED';

      // --- DYNAMIC ROUTING USING APP ROUTES ---
      final box = GetStorage();
      bool isConfigured = box.read('isConfigured') ?? false;

      if (!isConfigured) {
        // Route to Config Setup View using the Route constant
        Get.offAllNamed(Routes.CONFIG_SETUP, arguments: user);
      } else {
        // Skip setup and route to Dashboard (Assuming you will create a Routes.DASHBOARD)
        // Get.offAllNamed(Routes.DASHBOARD, arguments: user);

        // Placeholder success alert until Dashboard is built
        Get.snackbar(
          'ACCESS_GRANTED',
          'Routing to Main Dashboard...',
          backgroundColor: AppColors.success,
          colorText: AppColors.backgroundDark,
          borderRadius: 0,
        );
        Get.offAllNamed(Routes.CONFIG_SETUP, arguments: user);
      }
    } else {
      _showSystemAlert('AUTH_FAILED', 'Invalid Operator ID or Passcode.');
      nodeStatus.value = 'NODE_ONLINE';
      isStatusSuccess.value = false;
    }

    isLoading.value = false;
  }

  void _showSystemAlert(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.danger.withOpacity(0.9),
      colorText: AppColors.textMain,
      borderRadius: 0,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.warning_amber_rounded, color: AppColors.textMain),
    );
  }
}
