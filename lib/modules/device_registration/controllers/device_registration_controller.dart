import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for SCADA typography
import '../models/device_registration_model.dart';
// import '../../../core/routes/app_routes.dart'; // Uncomment if you want to use Routes.LOGIN

class DeviceRegistrationController extends GetxController {
  // Observables for UI State
  final terminalId = '8842-X-ALPHA'.obs;
  final isTokenObscured = true.obs;
  final isRegistering = false.obs;

  // Text Controllers for input fields
  final facilityCodeController = TextEditingController();
  final securityTokenController = TextEditingController();

  // Toggles the visibility of the security token field
  void toggleTokenVisibility() {
    isTokenObscured.value = !isTokenObscured.value;
  }

  // Core registration logic
  Future<void> registerTerminal() async {
    // 1. Basic Validation MUST happen first!
    if (facilityCodeController.text.trim().isEmpty ||
        securityTokenController.text.trim().isEmpty) {
      _showSystemDialog(
        title: 'VALIDATION ERROR',
        message: 'Facility Code and Security Token are required to proceed.',
        isError: true,
      );
      return;
    }

    // 2. Set loading state
    isRegistering.value = true;

    try {
      // 3. Package the data using the Model
      final registrationData = DeviceRegistrationModel(
        terminalId: terminalId.value,
        facilityCode: facilityCodeController.text.trim(),
        securityToken: securityTokenController.text.trim(),
      );

      // 4. Simulate API Call
      print('Sending Payload: ${registrationData.toJson()}');
      await Future.delayed(const Duration(seconds: 2));

      // 5. Save state locally ONLY AFTER API is successful
      final box = GetStorage();
      await box.write('isDeviceRegistered', true);

      // 6. Success Handling & Navigation
      _showSystemDialog(
        title: 'SYSTEM REGISTERED',
        message: 'Terminal has been authenticated and registered successfully on the local network.',
        isError: false,
        onAcknowledge: () {
          // 7. Navigate to Login ONLY AFTER they close the success dialog
          Get.offAllNamed('/login'); 
          // Note: If you use app_routes.dart, change to Get.offAllNamed(Routes.LOGIN);
        },
      );
    } catch (e) {
      // Error handling for API failures
      _showSystemDialog(
        title: 'REGISTRATION FAILED',
        message: 'An error occurred during authentication: ${e.toString()}',
        isError: true,
      );
    } finally {
      // 8. Reset loading state
      isRegistering.value = false;
    }
  }

  @override
  void onClose() {
    facilityCodeController.dispose();
    securityTokenController.dispose();
    super.onClose();
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
    // Define SCADA Colors based on your provided hex codes
    final Color bgColor = const Color(0xFF1E2226); // Surface color
    final Color borderColor = isError ? const Color(0xFF93000A) : const Color(0xFF05E777);
    final Color textColor = isError ? const Color(0xFFFFDAD6) : const Color(0xFF003918);

    Get.dialog(
      Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Sharp edges
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
              const Divider(color: Color(0xFF3A414A)),
              const SizedBox(height: 16),
              
              // Message Body
              Text(
                message,
                style: GoogleFonts.ibmPlexMono(
                  color: const Color(0xFFE8ECEF),
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
                    Get.back(); // Close the dialog
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