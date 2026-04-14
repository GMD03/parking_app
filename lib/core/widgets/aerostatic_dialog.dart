import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'aerostatic_button.dart';

class AerostaticDialog {
  /// Opens a modern, rounded dialog box matching the LuvPark Design Language.
  /// Supports Enter key to acknowledge/close.
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
      _AerostaticDialogContent(
        title: title,
        message: message,
        iconColor: iconColor,
        iconData: iconData,
        isError: isError,
        buttonLabel: customButtonLabel ?? 'ACKNOWLEDGE',
      ),
      barrierColor: AppColors.onSurface.withOpacity(0.4),
      barrierDismissible: true,
    ).whenComplete(() {
      if (onAcknowledge != null) {
        onAcknowledge();
      }
    });
  }

  /// Shows a brief toast/snackbar notification using the Aerostatic design system.
  static void toast({
    required String title,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final Color iconColor = isError ? AppColors.danger : AppColors.success;
    final IconData iconData = isError ? Icons.error_outline : Icons.check_circle_outline;

    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.surfaceContainerLowest,
      colorText: AppColors.onSurface,
      icon: Icon(iconData, color: iconColor, size: 28),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: AppColors.surfaceContainerLow,
      borderWidth: 2,
      duration: duration,
      titleText: Text(
        title,
        style: GoogleFonts.inter(
          color: AppColors.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.inter(
          color: AppColors.muted,
          fontSize: 13,
        ),
      ),
      boxShadows: const [
        BoxShadow(
          color: Color.fromRGBO(14, 29, 40, 0.08),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    );
  }
}

/// Stateful widget that handles keyboard focus for the dialog.
class _AerostaticDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final Color iconColor;
  final IconData iconData;
  final bool isError;
  final String buttonLabel;

  const _AerostaticDialogContent({
    required this.title,
    required this.message,
    required this.iconColor,
    required this.iconData,
    required this.isError,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              label: buttonLabel,
              isDestructive: isError,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
