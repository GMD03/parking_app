// lib/modules/dashboard/views/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/ticket_model.dart';
import '../../ticket_inspector/views/ticket_inspector_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          _buildTopNavBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTelemetrySidebar(),
                  const SizedBox(width: 24),
                  Expanded(child: _buildDataTableSection()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // --- TOP NAVBAR ---
  Widget _buildTopNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              Text('SYS.DASHBOARD.V2.0', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12, letterSpacing: 2)),
            ],
          ),
          Row(
            children: [
              Text('Operator ID: ', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12)),
              // Read directly from the controller's observable
              Obx(() => Text(controller.operatorId.value, style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 12))),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: controller.logout,
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

  // --- SIDEBAR: TELEMETRY ---
  Widget _buildTelemetrySidebar() {
    return SizedBox(
      width: 320,
      child: Column(
        children: [
          _buildSystemStatus(),
          const SizedBox(height: 16),
          _buildGlobalCapacity(),
          const SizedBox(height: 16),
          Expanded(child: _buildZoneBreakdown()), 
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SYSTEM STATUS', style: GoogleFonts.ibmPlexSans(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('ONLINE', style: GoogleFonts.ibmPlexMono(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Text(controller.currentTime.value, style: GoogleFonts.ibmPlexMono(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2))),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TERMINAL', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10)),
              // Bind Terminal ID
              Obx(() => Text(controller.terminalId.value, style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 10))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SYNC MODE', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10)),
              // Bind Sync Mode
              Obx(() => Text(controller.syncMode.value, style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 10))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalCapacity() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GLOBAL CAPACITY', style: GoogleFonts.ibmPlexSans(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(controller.availableSlots.value.toString().padLeft(3, '0'), style: GoogleFonts.ibmPlexMono(color: AppColors.success, fontSize: 36, fontWeight: FontWeight.bold))),
                  Text('AVAILABLE', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10)),
                ],
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(controller.totalCapacity.toString(), style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 24)),
                  Text('TOTAL', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() {
            final fillRatio = controller.totalCapacity > 0 ? controller.occupiedSlots.value / controller.totalCapacity : 0.0;
            return Column(
              children: [
                LinearProgressIndicator(
                  value: fillRatio,
                  backgroundColor: AppColors.backgroundDark,
                  color: fillRatio > 0.9 ? AppColors.danger : AppColors.primary,
                  minHeight: 4,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(fillRatio * 100).toStringAsFixed(1)}% FILLED', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10)),
                    Text('${controller.occupiedSlots.value} OCCUPIED', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10)),
                  ],
                )
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildZoneBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ZONE TELEMETRY', style: GoogleFonts.ibmPlexSans(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.zones.length,
              itemBuilder: (context, index) {
                final zone = controller.zones[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(zone.name, style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 12)),
                          Text('${zone.occupied} / ${zone.capacity}', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: zone.fillPercentage,
                        backgroundColor: AppColors.backgroundDark,
                        color: zone.fillPercentage > 0.9 ? AppColors.danger : AppColors.success,
                        minHeight: 2,
                      ),
                    ],
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }

  // --- MAIN DATATABLE SECTION ---
  Widget _buildDataTableSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          _buildTableColumns(),
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.filteredTickets.length,
              itemBuilder: (context, index) => _buildTableRow(controller.filteredTickets[index]),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt, color: AppColors.textMain, size: 18),
              const SizedBox(width: 12),
              Text('ACTIVE LOGS', style: GoogleFonts.ibmPlexSans(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
          SizedBox(
            width: 250,
            height: 36,
            child: TextField(
              controller: controller.searchController,
              style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'SEARCH PLATES / IDS...',
                hintStyle: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10),
                prefixIcon: const Icon(Icons.search, color: AppColors.muted, size: 16),
                filled: true,
                fillColor: AppColors.backgroundDark,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTableColumns() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('TICKET ID', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('LICENSE PLATE', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('TIME IN', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('DURATION', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('STATUS', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildTableRow(TicketModel ticket) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.generalDialog(
            barrierColor: Colors.black.withOpacity(0.8),
            barrierDismissible: true,
            barrierLabel: 'Inspector',
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (context, animation, secondaryAnimation) => TicketInspectorView(ticket: ticket),
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: child,
              );
            },
          );
        },
        hoverColor: AppColors.border.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              Expanded(flex: 1, child: Text(ticket.id, style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 14))),
              Expanded(flex: 2, child: Text(ticket.plate, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
              Expanded(flex: 2, child: Text(ticket.timeIn, style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 14))),
              Expanded(flex: 2, child: Text(ticket.duration, style: GoogleFonts.ibmPlexMono(color: Colors.white, fontSize: 14))),
              Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: _buildStatusBadge(ticket.status))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color color;
    String label;
    switch (status) {
      case TicketStatus.active:
        color = AppColors.success;
        label = 'ACTIVE';
        break;
      case TicketStatus.overstay:
        color = AppColors.danger;
        label = 'OVERSTAY';
        break;
      case TicketStatus.voided:
        color = AppColors.muted;
        label = 'VOID';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(label, style: GoogleFonts.ibmPlexMono(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 16),
      child: ElevatedButton(
        onPressed: controller.openNewTicketPanel,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          side: BorderSide(color: AppColors.primary.withOpacity(0.8), width: 1),
          elevation: 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 24),
            const SizedBox(width: 12),
            Text('[ NEW TICKET ]', style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withOpacity(0.2),
                border: Border.all(color: AppColors.backgroundDark.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text('kbd: F2', style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.backgroundDark)),
            )
          ],
        ),
      ),
    );
  }
}