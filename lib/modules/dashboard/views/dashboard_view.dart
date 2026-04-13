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
      backgroundColor: AppColors.surface,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset('assets/app_icon.ico', width: 20, height: 20),
              ),
              const SizedBox(width: 16),
              Text('LuvPark Dashboard', style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              Text('Operator ID: ', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14)),
              Obx(() => Text(controller.operatorId.value, style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600))),
              const SizedBox(width: 24),
              TextButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  backgroundColor: AppColors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
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
          const SizedBox(height: 24),
          _buildGlobalCapacity(),
          const SizedBox(height: 24),
          Expanded(child: _buildZoneBreakdown()), 
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SYSTEM STATUS', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('ONLINE', style: GoogleFonts.inter(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Obx(() => Text(controller.currentTime.value, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TERMINAL', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              Obx(() => Text(controller.terminalId.value, style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 12, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SYNC MODE', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              Obx(() => Text(controller.syncMode.value, style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 12, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TICKETS TODAY', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              Obx(() => Text(
                controller.ticketsToday.value.toString().padLeft(3, '0'),
                style: GoogleFonts.inter(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)
              )),
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
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GLOBAL CAPACITY', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(controller.availableSlots.value.toString().padLeft(3, '0'), style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 48, fontWeight: FontWeight.bold))),
                  Text('AVAILABLE', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              Container(width: 1, height: 40, color: AppColors.surfaceContainerLow),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(controller.totalCapacity.toString(), style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('TOTAL', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() {
            final fillRatio = controller.totalCapacity > 0 ? controller.occupiedSlots.value / controller.totalCapacity : 0.0;
            return Column(
               children: [
                 ClipRRect(
                   borderRadius: BorderRadius.circular(12),
                   child: LinearProgressIndicator(
                     value: fillRatio,
                     backgroundColor: AppColors.surfaceVariant,
                     color: fillRatio > 0.9 ? AppColors.danger : AppColors.primary,
                     minHeight: 12,
                   ),
                 ),
                 const SizedBox(height: 12),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text('${(fillRatio * 100).toStringAsFixed(1)}% FILLED', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                     Text('${controller.occupiedSlots.value} OCCUPIED', style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ZONE TELEMETRY', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() => ListView.separated(
              itemCount: controller.zones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final zone = controller.zones[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(zone.name, style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('${zone.occupied} / ${zone.capacity}', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: zone.fillPercentage,
                        backgroundColor: AppColors.surfaceVariant,
                        color: zone.fillPercentage > 0.9 ? AppColors.danger : AppColors.secondary,
                        minHeight: 8,
                      ),
                    ),
                  ],
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
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          _buildTableColumns(),
          Expanded(
            child: Obx(() => ListView.separated(
              itemCount: controller.filteredTickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _buildTableRow(controller.filteredTickets[index]),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Active Logs', style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(
            width: 300,
            height: 48,
            child: TextField(
              controller: controller.searchController,
              style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search plates / IDs...',
                hintStyle: GoogleFonts.inter(color: AppColors.muted, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.muted, size: 20),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTableColumns() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('TICKET ID', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('LICENSE PLATE', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('TIME IN', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('DURATION', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('STATUS', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildTableRow(TicketModel ticket) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if(ticket.status == TicketStatus.processing) return;
          Get.generalDialog(
            barrierColor: AppColors.onSurface.withOpacity(0.8),
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
        hoverColor: AppColors.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(flex: 1, child: Text(ticket.id, style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14))),
              Expanded(flex: 2, child: Text(ticket.plate, style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text(ticket.formattedTimeIn, style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14))),
              Expanded(flex: 2, child: Text(ticket.currentDuration, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600))),
              Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: _buildStatusBadge(ticket.status))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color color;
    Color bgColor;
    String label;
    
    switch (status) {
      case TicketStatus.active:
        color = AppColors.onSecondaryContainer;
        bgColor = AppColors.secondaryContainer;
        label = 'ACTIVE';
        break;
      case TicketStatus.overstay:
        color = AppColors.surfaceContainerLowest;
        bgColor = AppColors.danger;
        label = 'OVERSTAY';
        break;
      case TicketStatus.processing: 
        color = AppColors.surfaceContainerLowest;
        bgColor = AppColors.primary;
        label = 'PROCESSING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 83, 204, 0.4),
              blurRadius: 16,
              offset: Offset(0, 8),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: controller.openNewTicketPanel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.surfaceContainerLowest,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 24),
              const SizedBox(width: 12),
              Text('New Ticket', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}