import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/ticket_inspector_controller.dart';

class TicketInspectorView extends GetView<TicketInspectorController> {
  const TicketInspectorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 600,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 40, offset: Offset(0, 20)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildTransitTimeline(),
              _buildChargeCalculator(),
              _buildActionFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.3),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.ticket.plate,
            style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Text('[ X ]'),
            color: AppColors.muted,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            style: IconButton.styleFrom(foregroundColor: AppColors.muted)
                .copyWith(foregroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.hovered) ? AppColors.primary : AppColors.muted)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitTimeline() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Column(
        children: [
          _buildTimelineRow('TIME IN', controller.ticket.timeIn),
          const SizedBox(height: 16),
          // Using current time as dummy time out
          _buildTimelineRow('TIME OUT', '14:30:45'), 
          const SizedBox(height: 16),
          _buildTimelineRow('DURATION', controller.ticket.duration),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.5),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.ibmPlexSans(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          Text(value, style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 16, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildChargeCalculator() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.backgroundDark.withOpacity(0.2),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RATE MULTIPLIER', style: GoogleFonts.ibmPlexSans(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Text('P${controller.ratePerHour.toStringAsFixed(2)} / HR', style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 20, letterSpacing: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: Container(color: AppColors.primary.withOpacity(0.05))),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL DUE', style: GoogleFonts.ibmPlexSans(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      Text(controller.calculatedTotal, style: GoogleFonts.ibmPlexMono(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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

  Widget _buildActionFooter() {
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
              const Icon(Icons.info_outline, color: AppColors.muted, size: 16),
              const SizedBox(width: 8),
              Text('PRESS [ENTER] TO VALIDATE', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12, letterSpacing: 1.5)),
            ],
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessing.value ? null : controller.processCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              disabledBackgroundColor: AppColors.success.withOpacity(0.5),
              foregroundColor: AppColors.backgroundDark,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              elevation: 0,
            ),
            child: controller.isProcessing.value 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.backgroundDark, strokeWidth: 2))
              : Row(
                  children: [
                    Text('[ PROCESS CHECKOUT ]', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14)),
                    const SizedBox(width: 12),
                    const Icon(Icons.payments, size: 18),
                  ],
                ),
          )),
        ],
      ),
    );
  }
}