import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for SCADA typography
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class ReviewArmController extends GetxController {
  final isArming = false.obs;
  
  // You can load these from GetStorage if needed
  final totalCapacity = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final box = GetStorage();
    totalCapacity.value = box.read('totalFacilityCapacity') ?? 0;
  }

  void returnToZoneSetup() {
    Get.back();
  }

  Future<void> executeSystemArm() async {
    isArming.value = true;
    
    try {
      // Simulate hardware locking and API handshake
      await Future.delayed(const Duration(seconds: 2)); 

      // ONBOARDING COMPLETE: Save state globally
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