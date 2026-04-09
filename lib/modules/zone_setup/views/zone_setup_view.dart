import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/zone_setup_controller.dart';
import '../models/zone_setup_model.dart';

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
              // THE FIX: Stretch the Row vertically to prevent RenderFlex crash
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                _buildSidebar(context),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(48, 48, 48, 120), // Padding for sticky footer
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(),
                                  const SizedBox(height: 48),
                                  _buildTotalCapacitySection(),
                                  const SizedBox(height: 48),
                                  _buildZoneMatrixSection(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Sticky Footer
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: _buildStickyFooter(),
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

  // --- TOP APP BAR ---
  Widget _buildTopAppBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_4x4, color: AppColors.primary, size: 16),
              const SizedBox(width: 16),
              Text('SYS.INITIALIZATION.V1.4', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12, letterSpacing: 2)),
            ],
          ),
          Row(
            children: [
              Text('Operator ID: ', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12)),
              Text('ADMIN_01', style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 12)),
              const SizedBox(width: 16),
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
                  textStyle: GoogleFonts.ibmPlexMono(fontSize: 12),
                ).copyWith(
                  foregroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.hovered) ? AppColors.danger : AppColors.muted),
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
                Text('INITIALIZATION', style: GoogleFonts.ibmPlexSans(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text('Setup Protocol Active', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12, letterSpacing: 1)),
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
                      _buildStepItem(step: '01', title: 'System Config', status: 2), // 2 = Completed
                      const SizedBox(height: 32),
                      _buildStepItem(step: '02', title: 'Zone Setup', status: 1),    // 1 = Active
                      const SizedBox(height: 32),
                      _buildStepItem(step: '03', title: 'Review & Arm', status: 0),  // 0 = Pending
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

    if (status == 2) { // Completed
      iconColor = AppColors.border;
      bgColor = AppColors.surface;
      iconChild = const Icon(Icons.check, color: AppColors.muted, size: 16);
    } else if (status == 1) { // Active
      iconColor = AppColors.primary;
      bgColor = AppColors.primary;
      iconChild = const Icon(Icons.dns, color: AppColors.backgroundDark, size: 16);
    } else { // Pending
      iconColor = AppColors.border;
      bgColor = AppColors.backgroundDark;
      iconChild = Text(step, style: GoogleFonts.ibmPlexMono(color: AppColors.border, fontSize: 12));
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
            Text('Step $step', style: GoogleFonts.ibmPlexMono(color: status == 1 ? AppColors.primary : AppColors.muted.withOpacity(status == 0 ? 0.5 : 1), fontSize: 12)),
            const SizedBox(height: 4),
            Text(title.toUpperCase(), style: GoogleFonts.ibmPlexSans(color: status == 1 ? AppColors.textMain : AppColors.muted.withOpacity(status == 0 ? 0.5 : 1), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
        Text('ZONE SETUP & CAPACITY', style: GoogleFonts.ibmPlexSans(color: AppColors.textMain, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text('Define physical parking parameters prior to system arming.', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 14)),
      ],
    );
  }

  Widget _buildTotalCapacitySection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.storage, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('TOTAL FACILITY CAPACITY', style: GoogleFonts.ibmPlexSans(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ],
              ),
              Text('MAX SPOTS AVAILABLE', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.totalCapacityController,
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 32),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneMatrixSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_view, color: AppColors.textMain, size: 18),
                  const SizedBox(width: 8),
                  Text('LEVEL / ZONE MATRIX', style: GoogleFonts.ibmPlexSans(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ],
              ),
              Row(
                children: [
                  Obx(() => RichText(
                    text: TextSpan(
                      style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12),
                      children: [
                        const TextSpan(text: 'ALLOCATED: '),
                        TextSpan(text: '${controller.allocatedSpots.value}', style: const TextStyle(color: AppColors.textMain)),
                        TextSpan(text: ' / ${controller.totalCapacity.value}'),
                      ],
                    ),
                  )),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: controller.addNewZone,
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('ADD ZONE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // The Data Table Grid
        Container(
          decoration: BoxDecoration(color: AppColors.backgroundDark, border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              // Header Row
              Container(
                
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border))
                  ),
                child: Row(
                  children: [
                    Expanded(child: _buildGridHeaderCell('Zone ID / Name')),
                    Expanded(child: _buildGridHeaderCell('Allocated Spots', alignRight: true)),
                    Container(width: 80, padding: const EdgeInsets.all(12), child: Center(child: Text('Actions', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12)))),
                  ],
                ),
              ),
              // Dynamic Rows
              Obx(() => Column(
                children: controller.zoneRows.asMap().entries.map((entry) {
                  return _buildGridRow(entry.key, entry.value);
                }).toList(),
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Validation Warning
        Obx(() {
          final rem = controller.remainingSpots;
          final isError = rem < 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isError ? AppColors.danger.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
              border: Border.all(color: isError ? AppColors.danger.withOpacity(0.3) : AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(isError ? Icons.warning : Icons.info, color: isError ? AppColors.danger : AppColors.primary, size: 16),
                const SizedBox(width: 12),
                Text(
                  isError ? 'OVERCAPACITY: Reduce allocated spots by ${rem.abs()}.' 
                          : '$rem unallocated spots remaining. System can arm with partial allocation.',
                  style: GoogleFonts.ibmPlexMono(color: isError ? AppColors.danger : AppColors.primary, fontSize: 12),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGridHeaderCell(String title, {bool alignRight = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.border))),
      child: Text(
        title.toUpperCase(),
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12, letterSpacing: 1),
      ),
    );
  }

  Widget _buildGridRow(int index, ZoneRowData rowData) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.border))),
              child: TextField(
                controller: rowData.nameController,
                style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.border))),
              child: TextField(
                controller: rowData.spotsController,
                textAlign: TextAlign.right,
                style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ),
          Container(
            width: 80,
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.muted, size: 18),
              onPressed: () => controller.removeZone(index),
              hoverColor: AppColors.danger.withOpacity(0.1),
              color: AppColors.danger,
              splashRadius: 20,
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
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: controller.returnToConfig,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('RETURN TO CONFIG'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.muted,
              textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ),
          ElevatedButton(
            onPressed: controller.armSystem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              shadowColor: AppColors.primary.withOpacity(0.5),
              elevation: 8,
            ),
            child: Row(
              children: [
                Text('[ ARM PARKING SYSTEM ]', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(width: 12),
                const Icon(Icons.power_settings_new, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}