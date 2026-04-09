import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/ticket_model.dart';

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
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: AppColors.muted, size: 20),
              const SizedBox(width: 12),
              Obx(() => Text(
                controller.currentTime.value,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              )),
            ],
          ),
          Row(
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('SYNC: ONLINE', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(width: 24),
              OutlinedButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.power_settings_new, size: 16),
                label: const Text('[ LOGOUT ]'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.muted,
                  side: const BorderSide(color: AppColors.border),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: controller.syncNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  elevation: 0,
                ),
                child: Text('[ SYNC NOW ]', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TELEMETRY SIDEBAR ---
  Widget _buildTelemetrySidebar() {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          _buildTelemetryCard('AVAILABLE SLOTS', controller.availableSlots, AppColors.success),
          const SizedBox(height: 16),
          _buildTelemetryCard('OCCUPIED SLOTS', controller.occupiedSlots, Colors.white),
          const SizedBox(height: 16),
          _buildTelemetryCard('TICKETS TODAY', controller.ticketsToday, AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard(String title, RxInt value, Color valueColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Obx(() => Text(
            value.value.toString(),
            style: GoogleFonts.inter(
              color: valueColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          )),
        ],
      ),
    );
  }

  // --- DATA TABLE SECTION ---
  Widget _buildDataTableSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        children: [
          // Table Controls (Search)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 256,
                  height: 40,
                  child: TextField(
                    controller: controller.searchController,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.5),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: AppColors.muted, size: 18),
                      hintText: 'QUERY PLATE...',
                      hintStyle: GoogleFonts.inter(color: AppColors.muted),
                      filled: true,
                      fillColor: AppColors.backgroundDark,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.border)),
                      enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.border)),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.primary)),
                    ),
                  ),
                ),
                Obx(() => Text(
                  'Showing ${controller.filteredTickets.length} active records',
                  style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.5),
                )),
              ],
            ),
          ),
          
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                Expanded(flex: 1, child: _tableHeader('ID')),
                Expanded(flex: 2, child: _tableHeader('PLATE')),
                Expanded(flex: 2, child: _tableHeader('TIME_IN')),
                Expanded(flex: 2, child: _tableHeader('DURATION')),
                Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: _tableHeader('STATUS'))),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: Container(
              color: AppColors.backgroundDark,
              child: Obx(() => ListView.builder(
                itemCount: controller.filteredTickets.length,
                itemBuilder: (context, index) {
                  final ticket = controller.filteredTickets[index];
                  return _buildTableRow(ticket);
                },
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
    );
  }

  Widget _buildTableRow(TicketModel ticket) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {}, // Will open Inspector panel later
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
    String text;

    switch (status) {
      case TicketStatus.active:
        color = AppColors.success;
        text = 'Active';
        break;
      case TicketStatus.overstay:
        color = AppColors.danger;
        text = 'Overstay';
        break;
      case TicketStatus.processing:
        color = AppColors.primary;
        text = 'Processing';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  // --- FLOATING ACTION BUTTON ---
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
              child: Text('kbd: F2', style: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}