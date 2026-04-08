import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
      Get.snackbar(
        'Validation Error',
        'Facility Code and Security Token are required.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF93000A),
        colorText: const Color(0xFFFFDAD6),
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

      // 4. Simulate API Call
      print('Sending Payload: ${registrationData.toJson()}');
      await Future.delayed(const Duration(seconds: 2));

      // 5. Save state locally ONLY AFTER API is successful
      final box = GetStorage();
      await box.write('isDeviceRegistered', true);

      // 6. Success Handling
      Get.snackbar(
        'Success',
        'Terminal Registered Successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF05E777),
        colorText: const Color(0xFF003918),
        margin: const EdgeInsets.all(16),
      );

      // 7. Navigate directly to Login
      Get.offAllNamed('/login');
      // Note: If you are using your app_routes.dart, you can change the above to Get.offAllNamed(Routes.LOGIN);
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
}
