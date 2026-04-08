import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/config_controller.dart';
import '../models/config_model.dart';

class ConfigView extends GetView<ConfigController> {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      // Use Row for the split desktop layout
      body: Row(
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
                            const SizedBox(height: 48),
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
    // Constrain the sidebar width for desktop responsiveness
    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 360),
      width: MediaQuery.of(context).size.width * 0.3,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM INIT',
            style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            'HARDWARE SETUP',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 48),
          
          // Vertical Stepper
          Expanded(
            child: Stack(
              children: [
                // Vertical connecting line
                Positioned(
                  left: 11,
                  top: 24,
                  bottom: 0,
                  child: Container(width: 2, color: AppColors.border),
                ),
                Column(
                  children: [
                    _buildStepItem(
                      stepNumber: '01',
                      title: 'System Config',
                      subtitle: 'Establish telemetry connection parameters and synchronization rules.',
                      isActive: true,
                    ),
                    const SizedBox(height: 32),
                    _buildStepItem(
                      stepNumber: '02',
                      title: 'Zone Setup',
                      subtitle: 'Define physical facility capacity and sector mappings.',
                      isActive: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Text(
            'SYS.BUILD.8492 // SCADA_V2',
            style: GoogleFonts.ibmPlexMono(color: AppColors.border, fontSize: 10, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({required String stepNumber, required String title, required String subtitle, required bool isActive}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(right: 16, top: 2),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppColors.primary : AppColors.border, width: 2),
          ),
          child: isActive ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))) : null,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$stepNumber. $title'.toUpperCase(),
                style: GoogleFonts.inter(
                  color: isActive ? AppColors.primary : AppColors.muted,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(color: isActive ? AppColors.muted : AppColors.border, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
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
        style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      ),
    );
  }

  Widget _buildSyncModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DATA PIPELINE MODE', style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
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
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(4),
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
                    Text(title, style: GoogleFonts.inter(color: isSelected ? Colors.white : AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
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
        borderRadius: BorderRadius.circular(4),
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
                  Text('SYSTEM API KEY', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                  const SizedBox(height: 4),
                  Text('Required for secure handshake with central command.', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), border: Border.all(color: AppColors.success.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('PORT 443 OPEN', style: GoogleFonts.ibmPlexMono(color: AppColors.success, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller.apiKeyController,
            style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 14, letterSpacing: 2.0),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.key, color: AppColors.muted),
              filled: true,
              fillColor: AppColors.backgroundDark,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: controller.generateNewKey,
              child: Text(
                'GENERATE NEW KEY',
                style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                child: Text('[ LOGOUT ]', style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: controller.nextStage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.5),
            ),
            child: Row(
              children: [
                Text('[ NEXT STAGE ]', style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}