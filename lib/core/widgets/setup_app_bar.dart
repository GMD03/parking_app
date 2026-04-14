import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../../modules/login/controllers/login_controller.dart';
import '../services/database_service.dart';
import '../routes/app_routes.dart';

class SetupAppBar extends StatelessWidget {
  const SetupAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = LoginController.getCurrentUser();
    final operatorDisplay = currentUser?.operatorId ?? 'GUEST';
    
    // Obx context isn't needed here if it's purely static at load time, but just getting state is fine:
    final isConfigured = DatabaseService.getState('isConfigured') ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(14, 29, 40, 0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/logo.png', width: 36, height: 36),
              const SizedBox(width: 16),
              Text('LuvPark System Setup', style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              Text('Operator ID: ', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14)),
              Text(operatorDisplay, style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(width: 24),
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings, color: AppColors.muted),
                tooltip: 'System Options',
                color: AppColors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                position: PopupMenuPosition.under,
                onSelected: (value) {
                  if (value == 'dashboard') {
                    if (isConfigured) {
                      Get.offAllNamed(Routes.DASHBOARD);
                    } else {
                      Get.offAllNamed(Routes.LOGIN);
                    }
                  } else if (value == 'logout') {
                    Get.offAllNamed(Routes.LOGIN); // Add formal logout routine if needed in future
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'dashboard',
                    child: Row(
                      children: [
                        Icon(isConfigured ? Icons.dashboard : Icons.close, size: 18, color: isConfigured ? AppColors.primary : AppColors.muted),
                        const SizedBox(width: 12),
                        Text(isConfigured ? 'Dashboard' : 'Abort Setup', style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 18, color: AppColors.danger),
                        const SizedBox(width: 12),
                        Text('Logout', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
