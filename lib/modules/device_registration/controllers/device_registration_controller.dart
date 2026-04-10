// lib/modules/device_registration/controllers/device_registration_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/device_registration_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart'; // Ensure this points to your routes file

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
      _showSystemDialog(
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
      final box = GetStorage();
      // We save the boolean for the Splash screen routing logic
      await box.write('isDeviceRegistered', true);
      // We save the serialized model so global controllers can access the specific Terminal ID/Facility Code later
      await box.write(_storageKey, registrationData.toJson());

      // 5. Success Handling & Navigation
      _showSystemDialog(
        title: 'SYSTEM REGISTERED',
        message: 'Terminal has been authenticated and registered successfully on the local network.',
        isError: false,
        onAcknowledge: () {
          // Route to Login Control
          Get.offAllNamed(Routes.LOGIN); 
        },
      );
    } catch (e) {
      _showSystemDialog(
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
    final box = GetStorage();
    final data = box.read(_storageKey);
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

  // --- Custom SCADA Pop-up Dialog ---
  void _showSystemDialog({
    required String title,
    required String message,
    required bool isError,
    VoidCallback? onAcknowledge,
  }) {
    final Color bgColor = const Color(0xFF1E2226); 
    final Color borderColor = isError ? const Color(0xFF93000A) : const Color(0xFF05E777);
    final Color textColor = isError ? const Color(0xFFFFDAD6) : const Color(0xFF003918);

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
              const Divider(color: Color(0xFF3A414A)),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.ibmPlexMono(
                  color: const Color(0xFFE8ECEF),
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