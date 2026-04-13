import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/ticket_inspector_controller.dart';
import '../../dashboard/models/ticket_model.dart'; 

class TicketInspectorView extends StatelessWidget {
  final TicketModel ticket;

  const TicketInspectorView({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: GetBuilder<TicketInspectorController>(
          init: TicketInspectorController(ticket: ticket),
          builder: (controller) {
            return Container(
              width: 500,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9, 
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(14, 29, 40, 0.08),
                    blurRadius: 48,
                    offset: Offset(0, 24),
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(controller),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTransitTimeline(controller),
                            _buildChargeCalculator(controller),
                          ],
                        ),
                      ),
                    ),
                    _buildActionFooter(controller),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildHeader(TicketInspectorController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.ticket.plate,
                style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, size: 24),
                color: AppColors.muted,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                style: IconButton.styleFrom(foregroundColor: AppColors.muted)
                    .copyWith(foregroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.hovered) ? AppColors.danger : AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBadge('Class', controller.ticket.vehicleClass.toUpperCase(), AppColors.muted, AppColors.surfaceContainerLowest),
              const SizedBox(width: 8),
              _buildBadge('Zone', controller.ticket.zone.toUpperCase(), AppColors.primary, AppColors.surfaceContainerLowest),
              const SizedBox(width: 8),
              _buildBadge('Status', controller.ticket.status.name.toUpperCase(), _getStatusColor(controller.ticket.status), _getStatusBgColor(controller.ticket.status)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.active: return AppColors.onSecondaryContainer;
      case TicketStatus.overstay: return AppColors.surfaceContainerLowest;
      case TicketStatus.processing: return AppColors.surfaceContainerLowest;
    }
  }

  Color _getStatusBgColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.active: return AppColors.secondaryContainer;
      case TicketStatus.overstay: return AppColors.danger;
      case TicketStatus.processing: return AppColors.primary;
    }
  }

  Widget _buildBadge(String label, String value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text('$label: ', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.inter(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransitTimeline(TicketInspectorController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildTimelineRow('Time In', controller.ticket.formattedTimeIn),
          const SizedBox(height: 16),
          // Wrapped in Obx to update the duration LIVE
          Obx(() => _buildTimelineRow('Duration (LIVE)', controller.liveDuration)),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w600)),
          Text(value, style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChargeCalculator(TicketInspectorController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rate Class', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Text('P${controller.ratePerHour.toStringAsFixed(2)} / HR', style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow, // Higher emphasis
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Due', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Obx(() => Text(controller.calculatedTotal, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(TicketInspectorController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.muted, size: 20),
              const SizedBox(width: 8),
              Text('Press Enter to Check-Out', style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          Row(
            children: [
              _buildGateSelectorInline(controller),
              const SizedBox(width: 16),
              Obx(() => Container(
            decoration: BoxDecoration(
              gradient: controller.isProcessing.value ? null : const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryContainer],
              ),
              color: controller.isProcessing.value ? AppColors.surfaceContainerLow : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: controller.isProcessing.value ? [] : const [
                BoxShadow(
                  color: Color.fromRGBO(0, 83, 204, 0.4),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: controller.isProcessing.value ? null : controller.processCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledForegroundColor: AppColors.muted,
                foregroundColor: AppColors.surfaceContainerLowest,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: controller.isProcessing.value 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                : Row(
                    children: [
                      Text('Process Payment', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 8),
                      const Icon(Icons.payments, size: 18),
                    ],
                  ),
            ),
          )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGateSelectorInline(TicketInspectorController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'GATE:',
            style: GoogleFonts.inter(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedGate.value,
              dropdownColor: AppColors.surfaceContainerLowest,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 18),
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              isDense: true,
              onChanged: (String? newValue) {
                if (newValue != null) controller.selectGate(newValue);
              },
              items: controller.availableGates.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('Gate $value'),
                );
              }).toList(),
            ),
          )),
        ],
      ),
    );
  }
}