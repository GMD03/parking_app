import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/config_controller.dart';
import '../models/config_model.dart';
import '../../../core/widgets/aerostatic_button.dart';

class ConfigView extends GetView<ConfigController> {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Prevents RenderFlex layout crash
        children: [
          // Left Pane: Progression Sidebar
          _buildSidebar(context),
          
          // Right Pane: Main Configuration Area
          Expanded(
            child: Column(
              children: [
                // Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildSyncModeSection(),
                            const SizedBox(height: 48),
                            _buildApiConfigSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Sticky Footer Action Bar
                _buildStickyFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // SIDEBAR WIDGETS
  // ---------------------------------------------------------
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
                        stepNumber: '01',
                        title: 'System Config',
                        isActive: true,
                      ),
                      const SizedBox(height: 32),
                      _buildStepItem(
                        stepNumber: '02',
                        title: 'Zone Setup',
                        isActive: false,
                      ),
                      const SizedBox(height: 32),
                      _buildStepItem(
                        stepNumber: '03',
                        title: 'Review & Arm',
                        isActive: false,
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

  Widget _buildStepItem({required String stepNumber, required String title, required bool isActive}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.backgroundDark,
            border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
            boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)] : null,
          ),
          child: Center(
            child: isActive 
              ? const Icon(Icons.settings, color: AppColors.backgroundDark, size: 16)
              : Text(stepNumber, style: GoogleFonts.inter(color: AppColors.border, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Step $stepNumber'.toUpperCase(),
                style: GoogleFonts.inter(
                  color: isActive ? AppColors.primary : AppColors.muted.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                color: isActive ? AppColors.textMain : AppColors.muted.withOpacity(0.5), 
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.5
              ),
            ),
          ],
        )
      ],
    );
  }

  // ---------------------------------------------------------
  // MAIN CONTENT WIDGETS
  // ---------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Text(
        'SYNCHRONIZATION SETUP',
        style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      ),
    );
  }

  Widget _buildSyncModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DATA PIPELINE MODE', style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Text('Select how telemetry data is processed and stored.', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(child: _buildRadioCard(
              mode: SyncMode.local,
              title: 'LOCAL ONLY',
              description: 'Data remains strictly on-premise. No external transmission. Cloud features disabled.',
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildRadioCard(
              mode: SyncMode.cloud,
              title: 'CLOUD SYNC',
              description: 'Continuous real-time telemetry streaming to central command servers.',
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioCard({required SyncMode mode, required String title, required String description}) {
    return Obx(() {
      final isSelected = controller.syncMode.value == mode;
      return InkWell(
        onTap: () => controller.updateSyncMode(mode),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(top: 2, right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                ),
                child: isSelected ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))) : null,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(color: isSelected ? AppColors.primary : AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(description, style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildApiConfigSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SYSTEM API KEY', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  const SizedBox(height: 4),
                  Text('Required for secure handshake with central command.', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.1), 
                  border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3))
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('PORT 443 OPEN', style: GoogleFonts.inter(color: const Color(0xFF00E676), fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller.apiKeyController,
            style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 14, letterSpacing: 2.0),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.key, color: AppColors.muted),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              hintText: 'ENTER 32-CHAR KEY...',
              hintStyle: GoogleFonts.inter(color: AppColors.border, fontSize: 14, letterSpacing: 2.0),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: controller.generateNewKey,
              child: Text(
                'GENERATE NEW KEY',
                style: GoogleFonts.inter(color: AppColors.muted, fontSize: 10, letterSpacing: 1.0, decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.close, size: 18),
                label: const Text('ABORT'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textMain,
                  side: const BorderSide(color: AppColors.border),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => Get.offAllNamed('/login'),
                style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                child: Text('[ LOGOUT ]', style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ],
          ),
          AerostaticButton(
            width: 240,
            label: 'NEXT STAGE',
            icon: Icons.arrow_forward,
            onPressed: controller.nextStage,
          ),
        ],
      ),
    );
  }
}