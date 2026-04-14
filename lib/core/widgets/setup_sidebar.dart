import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../routes/app_routes.dart';
import '../services/database_service.dart';

class SetupSidebar extends StatelessWidget {
  final int currentStep;

  const SetupSidebar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final bool isConfigured = DatabaseService.getState('isConfigured') ?? false;

    return Container(
      width: 256,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INITIALIZATION',
                  style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 4),
                Text(
                  'Setup Protocol Active'.toUpperCase(),
                  style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, letterSpacing: 1),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Stack(
              children: [
                // Vertical connecting line
                Positioned(
                  left: 39,
                  top: 24,
                  bottom: 24,
                  child: Container(width: 1, color: AppColors.border),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildStepItem(
                        stepIndex: 1,
                        step: '01',
                        title: 'System Config',
                        status: isConfigured ? (currentStep == 1 ? 1 : 2) : (currentStep > 1 ? 2 : (currentStep == 1 ? 1 : 0)),
                        isConfigured: isConfigured,
                      ),
                      const SizedBox(height: 32),
                      _buildStepItem(
                        stepIndex: 2,
                        step: '02',
                        title: 'Zone Setup',
                        status: isConfigured ? (currentStep == 2 ? 1 : 2) : (currentStep > 2 ? 2 : (currentStep == 2 ? 1 : 0)),
                        isConfigured: isConfigured,
                      ),
                      const SizedBox(height: 32),
                      _buildStepItem(
                        stepIndex: 3,
                        step: '03',
                        title: 'Review & Arm',
                        status: isConfigured ? (currentStep == 3 ? 1 : 2) : (currentStep == 3 ? 1 : 0),
                        isConfigured: isConfigured,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'LuvPark System Core',
              style: GoogleFonts.inter(color: AppColors.border, fontSize: 10, letterSpacing: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({required int stepIndex, required String step, required String title, required int status, required bool isConfigured}) {
    Color iconColor;
    Color bgColor;
    Widget iconChild;

    if (status == 2) { 
      iconColor = AppColors.border;
      bgColor = AppColors.surface;
      iconChild = const Icon(Icons.check, color: AppColors.muted, size: 16);
    } else if (status == 1) { 
      iconColor = AppColors.primary;
      bgColor = AppColors.primary;
      IconData icon = Icons.settings;
      if (stepIndex == 2) icon = Icons.map;
      if (stepIndex == 3) icon = Icons.power_settings_new;
      iconChild = Icon(icon, color: AppColors.backgroundDark, size: 16);
    } else { 
      iconColor = AppColors.border;
      bgColor = AppColors.backgroundDark;
      iconChild = Text(step, style: GoogleFonts.inter(color: AppColors.border, fontSize: 12));
    }

    bool isClickable = isConfigured || status == 2;

    Widget item = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: iconColor),
            boxShadow: status == 1 ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)] : null,
          ),
          child: Center(child: iconChild),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Step $step'.toUpperCase(),
                style: GoogleFonts.inter(
                  color: status == 1 ? AppColors.primary : AppColors.muted.withOpacity(status == 0 ? 0.5 : 1),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                color: status == 1 ? AppColors.textMain : AppColors.muted.withOpacity(status == 0 ? 0.5 : 1), 
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.5
              ),
            ),
          ],
        )
      ],
    );

    if (isClickable && status != 1) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (stepIndex == 1) Get.offNamed(Routes.CONFIG_SETUP);
            else if (stepIndex == 2) Get.offNamed(Routes.ZONE_SETUP);
            else if (stepIndex == 3) Get.offNamed(Routes.REVIEW_ARM);
          },
          child: item,
        ),
      );
    }

    return item;
  }
}
