// lib/modules/review_arm/views/review_arm_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/review_arm_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../../../core/widgets/aerostatic_button.dart';
import '../../../core/widgets/setup_sidebar.dart';
import '../../../core/widgets/setup_app_bar.dart';
import '../../../core/widgets/setup_action_footer.dart';
import '../../../core/routes/app_routes.dart';

class ReviewArmView extends GetView<ReviewArmController> {
  const ReviewArmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          const SetupAppBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                const SetupSidebar(currentStep: 3),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 48),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      _buildSystemParameters(),
                                      const SizedBox(height: 24),
                                      _buildFacilityMapping(),
                                      const SizedBox(height: 24),
                                      _buildPricingRules(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 48),
                                Expanded(
                                  flex: 2,
                                  child: _buildCriticalWarning(),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() => SetupActionFooter(
            onBack: controller.returnToZoneSetup,
            backLabel: 'BACK TO ZONE SETUP',
            primaryLabel: 'ARM PARKING SYSTEM',
            primaryIcon: Icons.power_settings_new,
            isPrimaryLoading: controller.isArming.value,
            onPrimary: controller.isArming.value ? null : controller.executeSystemArm,
          )),
        ],
      ),
    );
  }



  // --- MAIN CONTENT PIECES ---
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('FINAL SYSTEM VALIDATION', style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 2)),
            const SizedBox(width: 16),
            Text('[ PRE-DEPLOYMENT_CHECK ]', style: GoogleFonts.inter(color: AppColors.primary.withOpacity(0.6), fontSize: 14, letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: 8),
        Text('All terminal parameters must be verified before engaging the global parking perimeter.', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14)),
      ],
    );
  }

  // CHANGED: Wrapped data rows in Obx to dynamically display controller values
  Widget _buildSystemParameters() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SYSTEM PARAMETERS', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: AppColors.backgroundDark,
                child: Obx(() => Text('REF_ID: ${controller.terminalId.value}', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 10))),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Obx(() => _buildDataReadout('Sync Mode', controller.syncMode.value))),
              Expanded(child: Obx(() => _buildDataReadout('API Key Status', controller.apiKeyStatus.value, isVerified: controller.apiKeyStatus.value == 'AUTHENTICATED'))),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildDataReadout('Telemetry Rate', '10ms / 60Hz')), // Usually fixed
              Expanded(child: _buildDataReadout('Encryption', 'AES-256-SCADA')), // Usually fixed
            ],
          ),
        ],
      ),
    );
  }

  // CHANGED: Wrapped Zone data in Obx to dynamically display values
  Widget _buildFacilityMapping() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text('FACILITY MAPPING', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() => _buildRowItem('Total Zones', controller.totalZones.value.toString())),
          const Divider(color: AppColors.border, height: 24),
          Obx(() => _buildRowItem('Total Capacity', controller.totalCapacity.value.toString())),
          const Divider(color: AppColors.border, height: 24),
          _buildRowItem('Gate Nodes', '2'), // Keep static or link to Device Model later
        ],
      ),
    );
  }

  // NEW: Pricing rules validation section
  Widget _buildPricingRules() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text('PRICING PROTOCOLS', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() => _buildRowItem('Grace Period', '${controller.gracePeriod.value} min')),
          const Divider(color: AppColors.border, height: 24),
          Obx(() => _buildRowItem('Base Rate', '₱${controller.baseRate.value.toStringAsFixed(2)}')),
          const Divider(color: AppColors.border, height: 24),
          Obx(() => _buildRowItem('Overstay Rate', '₱${controller.succeedingRate.value.toStringAsFixed(2)} / hr')),
          const Divider(color: AppColors.border, height: 24),
          Obx(() => _buildRowItem('Overnight Rate', '₱${controller.overnightRate.value.toStringAsFixed(2)}')),
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14)),
        Text(value, style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 24)),
      ],
    );
  }

  Widget _buildDataReadout(String label, String value, {bool isVerified = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (isVerified) ...[
              const Icon(Icons.verified, color: AppColors.success, size: 14),
              const SizedBox(width: 6),
            ],
            Text(
              value, 
              style: GoogleFonts.inter(
                color: isVerified ? AppColors.success : AppColors.textMain, 
                fontSize: 16, 
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCriticalWarning() {
    return Column(
      children: [
        // Critical Action Box
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceContainerLow),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning, color: AppColors.danger, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'CRITICAL: Arming the system overrides manual gate control and initiates high-voltage solenoid engagement.',
                        style: GoogleFonts.inter(color: AppColors.danger, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ESTIMATED SPINDOWN: 2.4s', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 10)),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('HARDWARE READY', style: GoogleFonts.inter(color: AppColors.success, fontSize: 10, letterSpacing: 1)),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}