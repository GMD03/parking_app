import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/zone_setup_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../../../core/widgets/aerostatic_button.dart';

class ZoneSetupView extends GetView<ZoneSetupController> {
  const ZoneSetupView({super.key});

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
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 48),
                            _buildTotalCapacityCard(),
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
        ],
      ),
    );
  }

  // --- TOP APP BAR ---
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
                ).copyWith(
                  foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.hovered) ? AppColors.danger : AppColors.muted),
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
                      _buildStepItem(step: '02', title: 'Zone Setup', status: 1),    
                      const SizedBox(height: 32),
                      _buildStepItem(step: '03', title: 'Review & Arm', status: 0),  
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
      iconChild = const Icon(Icons.map, color: AppColors.backgroundDark, size: 16);
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
// (Only the _buildActionArea method needs to be replaced)

  Widget _buildActionArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: controller.returnToConfig,
          icon: const Icon(Icons.arrow_back, size: 14),
          label: const Text('RETURN TO CONFIG'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.muted,
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12),
          ),
        ),
        Row(
          children: [
            Obx(() {
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
            const SizedBox(width: 32),
            Obx(() {
               // Only enable the button if the allocation is perfectly 0
               final isReady = controller.remainingSpots == 0;
               
               return SizedBox(
                 width: 250,
                 child: AerostaticButton(
                  label: 'VALIDATE & PROCEED',
                  icon: Icons.arrow_forward,
                  onPressed: isReady ? controller.armSystem : null,
                ),
               );
            }),
          ],
        )
      ],
    );
  }
}