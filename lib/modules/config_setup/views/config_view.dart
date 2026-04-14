import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/config_controller.dart';
import '../models/config_model.dart';
import '../../../core/widgets/aerostatic_button.dart';
import '../../login/controllers/login_controller.dart';
import '../../../core/services/database_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/setup_sidebar.dart';
import '../../../core/widgets/setup_app_bar.dart';
import '../../../core/widgets/setup_action_footer.dart';

class ConfigView extends GetView<ConfigController> {
  const ConfigView({super.key});

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
                // Left Pane: Progression Sidebar
                const SetupSidebar(currentStep: 1),
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
                                  _buildDynamicConfigSection(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Sticky Footer Action Bar
                      SetupActionFooter(
                        primaryLabel: 'NEXT STAGE',
                        onPrimary: controller.nextStage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  // ---------------------------------------------------------
  // MAIN CONTENT WIDGETS
  // ---------------------------------------------------------
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('FACILITY SYNC', style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 2)),
            const SizedBox(width: 16),
            Text('[ SYSTEM_CONFIG ]', style: GoogleFonts.inter(color: AppColors.primary.withOpacity(0.6), fontSize: 14, letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: 8),
        Text('Configure the synchronization pipeline and hardware communication parameters.', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14)),
      ],
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
        mouseCursor: SystemMouseCursors.click,
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

  Widget _buildDynamicConfigSection() {
    return Obx(() {
      final isCloud = controller.syncMode.value == SyncMode.cloud;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHardwareConfigSection(),
          if (isCloud) ...[
            const SizedBox(height: 48),
            _buildApiConfigSection(),
          ]
        ],
      );
    });
  }

  Widget _buildHardwareConfigSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HARDWARE DAEMON ROUTING', style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text('Configure the NP3300 edge controller IP addresses and Site Name.', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTextField('ENTRY IP', controller.entryIpCtrl)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('ENTRY PORT', controller.entryPortCtrl, isNumber: true)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('EXIT IP', controller.exitIpCtrl)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('EXIT PORT', controller.exitPortCtrl, isNumber: true)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('SITE NAME', controller.siteNameCtrl),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 14, letterSpacing: 1.0),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
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
              mouseCursor: SystemMouseCursors.click,
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
}