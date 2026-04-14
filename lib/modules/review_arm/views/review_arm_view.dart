// lib/modules/review_arm/views/review_arm_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/review_arm_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../../../core/widgets/aerostatic_button.dart';

class ReviewArmView extends GetView<ReviewArmController> {
  const ReviewArmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          _buildTopAppBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                _buildSidebar(context),
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
                                  child: _buildActionArea(),
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
        ],
      ),
    );
  }

  // --- TOP APP BAR (Shared) ---
  Widget _buildTopAppBar() {
    final currentUser = LoginController.getCurrentUser();
    final operatorDisplay = currentUser?.operatorId ?? 'GUEST';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest, // Matches dashboard
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
              OutlinedButton.icon(
                onPressed: () => Get.offAllNamed('/login'),
                icon: const Icon(Icons.logout, size: 14),
                label: const Text('[ LOGOUT ]'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.muted,
                  side: const BorderSide(color: AppColors.border),
                  backgroundColor: AppColors.surface.withOpacity(0.5),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: GoogleFonts.inter(fontSize: 12),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // --- SIDEBAR ---
  Widget _buildSidebar(BuildContext context) {
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
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('INITIALIZATION', style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text('Setup Protocol Active', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, letterSpacing: 1)),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(left: 39, top: 24, bottom: 24, child: Container(width: 1, color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildStepItem(step: '01', title: 'System Config', status: 2), 
                      const SizedBox(height: 32),
                      _buildStepItem(step: '02', title: 'Zone Setup', status: 2),    
                      const SizedBox(height: 32),
                      _buildStepItem(step: '03', title: 'Review & Arm', status: 1),  
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepItem({required String step, required String title, required int status}) {
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
      iconChild = const Icon(Icons.power_settings_new, color: AppColors.backgroundDark, size: 16);
    } else { 
      iconColor = AppColors.border;
      bgColor = AppColors.backgroundDark;
      iconChild = Text(step, style: GoogleFonts.inter(color: AppColors.border, fontSize: 12));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: iconColor),
            boxShadow: status == 1 ? [const BoxShadow(color: Color(0x4DF9AC06), blurRadius: 8)] : null,
          ),
          child: Center(child: iconChild),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step $step', style: GoogleFonts.inter(color: status == 1 ? AppColors.primary : AppColors.muted.withOpacity(status == 0 ? 0.5 : 1), fontSize: 12)),
            const SizedBox(height: 4),
            Text(title.toUpperCase(), style: GoogleFonts.inter(color: status == 1 ? AppColors.textMain : AppColors.muted.withOpacity(status == 0 ? 0.5 : 1), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        )
      ],
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

  Widget _buildActionArea() {
    return Column(
      children: [
        // Top Return Button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: controller.returnToZoneSetup,
            icon: const Icon(Icons.arrow_back, size: 14),
            label: const Text('BACK TO ZONE SETUP'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.muted,
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
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
              
              Obx(() => AerostaticButton(
                label: 'ARM PARKING SYSTEM',
                icon: Icons.power_settings_new,
                isLoading: controller.isArming.value,
                onPressed: controller.isArming.value ? null : controller.executeSystemArm,
              )),
              
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