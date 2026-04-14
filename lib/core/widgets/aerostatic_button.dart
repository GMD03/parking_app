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
    
    // Gradient colors: blue→cyan for primary, red tones for destructive
    final List<Color> gradientColors = isDestructive
        ? [AppColors.danger, AppColors.danger.withValues(alpha: 0.8)]
        : [AppColors.primaryContainer, AppColors.secondary];

    return Container(
      width: width,
      height: 56,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: isDisabled ? AppColors.surfaceContainerHigh : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDisabled
            ? null
            : isDestructive
                ? [
                    BoxShadow(
                      color: AppColors.danger.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                      spreadRadius: -4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        color: isDisabled ? AppColors.muted : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 10),
                      Icon(icon,
                          color: isDisabled ? AppColors.muted : Colors.white,
                          size: 18),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
