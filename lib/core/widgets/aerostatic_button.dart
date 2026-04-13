import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AerostaticButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool isDestructive;
  final double? width;
  
  const AerostaticButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isDestructive = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    
    // Choose colors based on status
    final List<Color> gradientColors = isDestructive
        ? [AppColors.danger, AppColors.danger.withOpacity(0.8)]
        : [AppColors.primary, AppColors.primaryContainer];
        
    final Color shadowColor = isDestructive
        ? AppColors.danger.withOpacity(0.4)
        : const Color.fromRGBO(0, 83, 204, 0.4);

    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : LinearGradient(colors: gradientColors),
        color: isDisabled ? AppColors.surfaceContainerHigh : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: isDisabled ? AppColors.muted : Colors.white, size: 20),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        color: isDisabled ? AppColors.muted : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
