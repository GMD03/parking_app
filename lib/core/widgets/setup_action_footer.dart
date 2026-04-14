import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'aerostatic_button.dart';

class SetupActionFooter extends StatelessWidget {
  final VoidCallback? onBack;
  final String backLabel;
  final VoidCallback? onPrimary;
  final String primaryLabel;
  final IconData primaryIcon;
  final bool isPrimaryLoading;

  const SetupActionFooter({
    super.key,
    this.onBack,
    this.backLabel = 'BACK',
    this.onPrimary,
    required this.primaryLabel,
    this.primaryIcon = Icons.arrow_forward,
    this.isPrimaryLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onBack != null)
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 14),
              label: Text(backLabel),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.muted,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12),
              ).copyWith(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered) ? AppColors.textMain : AppColors.muted,
                ),
              ),
            )
          else
            const SizedBox.shrink(), // Empty space if no back button
          AerostaticButton(
            width: 260, // Wide enough for critical labels
            label: primaryLabel,
            icon: primaryIcon,
            onPressed: onPrimary,
            isLoading: isPrimaryLoading,
          ),
        ],
      ),
    );
  }
}
