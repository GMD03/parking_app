import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'aerostatic_button.dart';

class AerostaticDialog {
  /// Opens a modern, rounded dialog box matching the LuvPark Design Language.
  static void show({
    required String title,
    required String message,
    required bool isError,
    VoidCallback? onAcknowledge,
    String? customButtonLabel,
  }) {
    final Color iconColor = isError ? AppColors.danger : AppColors.success;
    final IconData iconData = isError ? Icons.warning_rounded : Icons.check_circle_rounded;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(14, 29, 40, 0.1),
                blurRadius: 48,
                offset: Offset(0, 24),
              )
            ],
            border: Border.all(color: AppColors.surfaceContainerLow, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: iconColor.withOpacity(0.1),
                       shape: BoxShape.circle,
                     ),
                     child: Icon(iconData, color: iconColor, size: 28),
                   ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: GoogleFonts.inter(
                  color: AppColors.muted,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              AerostaticButton(
                label: customButtonLabel ?? 'ACKNOWLEDGE',
                isDestructive: isError,
                onPressed: () {
                  Get.back();
                  if (onAcknowledge != null) {
                    onAcknowledge();
                  }
                },
              ),
            ],
          ),
        ),
      ),
      barrierColor: AppColors.onSurface.withOpacity(0.4),
      barrierDismissible: false,
    );
  }
}
