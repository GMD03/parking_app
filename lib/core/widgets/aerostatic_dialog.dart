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

    void handleAcknowledge() {
      Get.back();
      if (onAcknowledge != null) {
        onAcknowledge();
      }
    }

    Get.dialog(
      _AerostaticDialogContent(
        title: title,
        message: message,
        iconColor: iconColor,
        iconData: iconData,
        isError: isError,
        buttonLabel: customButtonLabel ?? 'ACKNOWLEDGE',
        onAcknowledge: handleAcknowledge,
      ),
      barrierColor: AppColors.onSurface.withOpacity(0.4),
      barrierDismissible: false,
    );
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
class _AerostaticDialogContent extends StatefulWidget {
  final String title;
  final String message;
  final Color iconColor;
  final IconData iconData;
  final bool isError;
  final String buttonLabel;
  final VoidCallback onAcknowledge;

  const _AerostaticDialogContent({
    required this.title,
    required this.message,
    required this.iconColor,
    required this.iconData,
    required this.isError,
    required this.buttonLabel,
    required this.onAcknowledge,
  });

  @override
  State<_AerostaticDialogContent> createState() => _AerostaticDialogContentState();
}

class _AerostaticDialogContentState extends State<_AerostaticDialogContent> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus after frame renders so keyboard events are captured immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
             event.logicalKey == LogicalKeyboardKey.numpadEnter ||
             event.logicalKey == LogicalKeyboardKey.escape)) {
          widget.onAcknowledge();
        }
      },
      child: Dialog(
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
                      color: widget.iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.iconData, color: widget.iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.title,
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
                widget.message,
                style: GoogleFonts.inter(
                  color: AppColors.muted,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              // Keyboard hint
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Enter ↵',
                      style: GoogleFonts.inter(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'to acknowledge',
                    style: GoogleFonts.inter(color: AppColors.muted, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AerostaticButton(
                label: widget.buttonLabel,
                isDestructive: widget.isError,
                onPressed: widget.onAcknowledge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
