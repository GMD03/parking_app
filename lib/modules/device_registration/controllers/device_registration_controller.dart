import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/device_registration_model.dart'; // Ensure you created this model file

class DeviceRegistrationController extends GetxController {
  // Observables for UI State
  final terminalId = '8842-X-ALPHA'.obs; // Mock static terminal ID from your UI
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
    // 1. Basic Validation
    if (facilityCodeController.text.trim().isEmpty ||
        securityTokenController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Facility Code and Security Token are required.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(
          0xFF93000A,
        ), // error-container color from your UI
        colorText: const Color(0xFFFFDAD6), // on-error-container color
        margin: const EdgeInsets.all(16),
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

      // 4. Simulate API Call (Replace this with your actual HTTP/API call)
      // Example: await apiService.post('/api/v1/devices/register', registrationData.toJson());
      print('Sending Payload: ${registrationData.toJson()}');
      await Future.delayed(const Duration(seconds: 2));

      // 5. Success Handling
      Get.snackbar(
        'Success',
        'Terminal Registered Successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(
          0xFF05E777,
        ), // secondary-container from your UI
        colorText: const Color(0xFF003918), // on-secondary-container
        margin: const EdgeInsets.all(16),
      );

      // TODO: Save to local storage (SharedPreferences / GetStorage) that device is registered
      // so this screen doesn't show up again on app restart.

      // 6. Navigate to the next screen (e.g., Dashboard or Login)
      // Get.offAllNamed('/login');
    } catch (e) {
      // Error handling for API failures
      Get.snackbar(
        'Registration Failed',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF93000A),
        colorText: const Color(0xFFFFDAD6),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      // 7. Reset loading state
      isRegistering.value = false;
    }
  }

  @override
  void onClose() {
    // Always dispose controllers to prevent memory leaks
    facilityCodeController.dispose();
    securityTokenController.dispose();
    super.onClose();
  }
}
