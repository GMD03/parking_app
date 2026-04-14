import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/zone_setup_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../../../core/widgets/aerostatic_button.dart';
import '../../../core/widgets/setup_sidebar.dart';
import '../../../core/widgets/setup_app_bar.dart';
import '../../../core/widgets/setup_action_footer.dart';
import '../../../core/routes/app_routes.dart';

class ZoneSetupView extends GetView<ZoneSetupController> {
  const ZoneSetupView({super.key});

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
                const SetupSidebar(currentStep: 2),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 48),
                            _buildTotalCapacityCard(),
                            const SizedBox(height: 32),
                            _buildPricingRulesCard(),
                            const SizedBox(height: 32),
                            _buildZoneList(),
                            const SizedBox(height: 48),
                            _buildActionArea(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final isReady = controller.remainingSpots == 0;
            return SetupActionFooter(
              onBack: controller.returnToConfig,
              backLabel: 'BACK TO SYSTEM CONFIG',
              primaryLabel: 'VALIDATE & PROCEED',
              onPrimary: isReady ? controller.armSystem : null,
            );
          }),
        ],
      ),
    );
  }



  // --- MAIN CONTENT ---
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('FACILITY MAPPING', style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 2)),
            const SizedBox(width: 16),
            Text('[ ZONE_ALLOCATION ]', style: GoogleFonts.inter(color: AppColors.primary.withOpacity(0.6), fontSize: 14, letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: 8),
        Text('Define the physical structure of the parking facility. Allocated zones must not exceed total physical capacity.', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14)),
      ],
    );
  }

  Widget _buildTotalCapacityCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL PHYSICAL CAPACITY', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text('The absolute maximum number of parking spots available across all zones.', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 32),
          SizedBox(
            width: 200,
            child: TextField(
              controller: controller.totalCapacityController,
              style: GoogleFonts.inter(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRulesCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PRICING & GRACE RULES', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('Define billing parameters for the specific site environment. Amounts are in local currency.', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 32),
          _buildScheduleDropdown(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildPricingField('GRACE PERIOD (MINS)', controller.gracePeriodCtrl)),
              const SizedBox(width: 16),
              Expanded(child: _buildPricingField('BASE HOURS', controller.baseHoursCtrl)),
              const SizedBox(width: 16),
              Expanded(child: _buildPricingField('BASE RATE', controller.baseRateCtrl, prefix: 'P')),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final isOvernight = controller.selectedScheduleType.value.contains('Overnight');
            return Row(
              children: [
                Expanded(child: _buildPricingField('SUCCEEDING PERIOD (HRS)', controller.succeedingPeriodCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildPricingField('OVERSTAY RATE', controller.overstayRateCtrl, prefix: 'P')),
                if (isOvernight) ...[
                  const SizedBox(width: 16),
                  Expanded(child: _buildPricingField('OVERNIGHT RATE', controller.overnightRateCtrl, prefix: 'P')),
                ] else ...[
                  const SizedBox(width: 16),
                  Expanded(child: const SizedBox()),
                ]
              ],
            );
          }),
        ],
      )
    );
  }

  Widget _buildPricingField(String label, TextEditingController textController, {String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
          style: GoogleFonts.inter(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: prefix != null ? '$prefix ' : null,
            prefixStyle: GoogleFonts.inter(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SCHEDULE / BILLING TYPE', style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Obx(() => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
             child: DropdownButton<String>(
               value: controller.selectedScheduleType.value,
               isExpanded: true,
               dropdownColor: AppColors.surfaceContainerLowest,
               icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
               style: GoogleFonts.inter(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
               onChanged: (String? newValue) {
                 if (newValue != null) controller.selectedScheduleType.value = newValue;
               },
               items: const [
                 DropdownMenuItem(value: 'regular', child: Text('Regular Rate')),
                 DropdownMenuItem(value: 'regularWithOvernight', child: Text('Regular Rate with Overnight')),
                 DropdownMenuItem(value: 'twentyFourHours', child: Text('24 Hours Rate')),
                 DropdownMenuItem(value: 'twentyFourHoursWithOvernight', child: Text('24 Hours Rate with Overnight')),
               ],
             )
          ),
        )),
      ],
    );
  }

  Widget _buildZoneList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('ZONE IDENTIFIER', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
                Expanded(flex: 2, child: Text('ALLOCATED SPOTS', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
                const SizedBox(width: 48), // Space for delete button
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          // Dynamic List
          Obx(() => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.zoneRows.length,
                separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                itemBuilder: (context, index) {
                  final rowData = controller.zoneRows[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: rowData.nameController,
                            style: GoogleFonts.inter(color: AppColors.textMain, fontSize: 14),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.primary)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: rowData.spotsController,
                            style: GoogleFonts.inter(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.primary)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () => controller.removeZone(index),
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                          tooltip: 'Remove Zone',
                          splashRadius: 20,
                        )
                      ],
                    ),
                  );
                },
              )),
          const Divider(color: AppColors.border, height: 1),
          
          // Add Zone Button
          InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: controller.addNewZone,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Text('[ APPEND NEW ZONE ]', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

// lib/modules/zone_setup/views/zone_setup_view.dart

  Widget _buildActionArea() {
    return Align(
      alignment: Alignment.centerRight,
      child: Obx(() {
              final remaining = controller.remainingSpots;
              
              // Determine visual state based on allocation accuracy
              bool isPerfect = remaining == 0;
              bool isOverload = remaining < 0;
              
              Color boxColor;
              Color textColor;
              
              if (isPerfect) {
                boxColor = AppColors.success.withOpacity(0.1);
                textColor = AppColors.success;
              } else if (isOverload) {
                boxColor = AppColors.danger.withOpacity(0.1);
                textColor = AppColors.danger;
              } else {
                // Incomplete allocation gets a muted/amber treatment
                boxColor = AppColors.surface;
                textColor = const Color(0xFFF9AC06); // Amber/Warning
              }

              return Row(
                children: [
                  Text(
                    isPerfect ? 'ALLOCATION COMPLETE:' : 'REMAINING CAPACITY:', 
                    style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12)
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: textColor),
                    ),
                    child: Text(
                      remaining.toString(),
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              );
            }),
    );
  }
}