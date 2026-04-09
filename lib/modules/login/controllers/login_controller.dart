import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; 
import 'package:google_fonts/google_fonts.dart'; // Added for SCADA typography
import '../models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart'; 

class LoginController extends GetxController {
  // UI Controls
  final operatorIdController = TextEditingController();
  final passcodeController = TextEditingController();

  // Reactive State Variables
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
      _showSystemDialog(
        title: 'ACCESS DENIED', 
        message: 'Missing credentials. Please provide Operator ID and Passcode.', 
        isError: true
      );
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

      final box = GetStorage();
      bool isConfigured = box.read('isConfigured') ?? false;

      if (!isConfigured) {
        // First-time setup flow: Route directly to config without pop-up interruption
        Get.offAllNamed(Routes.CONFIG_SETUP, arguments: user);
      } else {
        // App is already configured: Show Success Dialog, then proceed to Dashboard
        _showSystemDialog(
          title: 'ACCESS GRANTED',
          message: 'Authentication verified. Routing to Main Dashboard...',
          isError: false,
          onAcknowledge: () {
            Get.offAllNamed(Routes.DASHBOARD, arguments: user);
          }
        );
      }
    } else {
      // Failed Auth Check
      _showSystemDialog(
        title: 'AUTH FAILED', 
        message: 'Invalid Operator ID or Passcode.', 
        isError: true
      );
      nodeStatus.value = 'NODE_ONLINE';
      isStatusSuccess.value = false;
    }

    isLoading.value = false;
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
    // Using your AppColors for consistent theming
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
              // Header Row
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
              
              // Message Body
              Text(
                message,
                style: GoogleFonts.ibmPlexMono(
                  color: AppColors.textMain,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close the dialog first
                    if (onAcknowledge != null) {
                      onAcknowledge(); // Execute routing if provided
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
      barrierDismissible: false, // Forces the user to click the acknowledge button
    );
  }
}