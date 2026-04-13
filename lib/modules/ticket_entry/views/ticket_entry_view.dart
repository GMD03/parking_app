import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/ticket_entry_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../dashboard/models/ticket_model.dart';

class TicketEntryView extends StatelessWidget {
  const TicketEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: GetBuilder<TicketEntryController>(
          init: TicketEntryController(),
          builder: (controller) {
            return Container(
              width: 400,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(14, 29, 40, 0.08),
                    blurRadius: 48,
                    offset: Offset(-12, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(controller),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLicensePlateInput(controller),
                          const SizedBox(height: 32),
                          _buildVehicleClassSelector(controller),
                          const SizedBox(height: 32),
                          _buildZoneSelector(controller),
                          const SizedBox(height: 32),
                          _buildGateSelector(controller),
                          const SizedBox(height: 32),
                          _buildRecentLogSection(controller),
                        ],
                      ),
                    ),
                  ),

                  _buildFooter(controller),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(TicketEntryController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Entry Log',
                style: GoogleFonts.inter(
                  color: AppColors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manual Override',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: AppColors.muted, size: 24),
            splashRadius: 24,
            hoverColor: AppColors.danger.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildLicensePlateInput(TicketEntryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LICENSE PLATE',
          style: GoogleFonts.inter(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.plateController,
          autofocus: true,
          style: GoogleFonts.inter(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            hintText: 'Enter Plate',
            hintStyle: GoogleFonts.inter(
              color: AppColors.outlineVariant,
              fontSize: 18,
              letterSpacing: 0,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleClassSelector(TicketEntryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLASSIFICATION',
          style: GoogleFonts.inter(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildClassOption(controller, VehicleClass.car, 'Class A', 'Sedan/SUV')),
            const SizedBox(width: 12),
            Expanded(child: _buildClassOption(controller, VehicleClass.truck, 'Class B', 'Truck/Van')),
          ],
        ),
        const SizedBox(height: 12),
        _buildClassOption(controller, VehicleClass.moto, 'Class C', 'Motorcycle'),
      ],
    );
  }

  Widget _buildZoneSelector(TicketEntryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ASSIGN ZONE',
          style: GoogleFonts.inter(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Obx(() {
            if (controller.availableZones.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'NO AVAILABLE ZONES (FULL)',
                  style: GoogleFonts.inter(
                    color: AppColors.danger,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedZone.value.isEmpty ? null : controller.selectedZone.value,
                dropdownColor: AppColors.surfaceContainerLowest,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.muted),
                isExpanded: true,
                style: GoogleFonts.inter(
                  color: AppColors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) controller.selectZone(newValue);
                },
                items: controller.availableZones.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGateSelector(TicketEntryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ASSIGN GATE',
          style: GoogleFonts.inter(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: controller.availableGates.map((gate) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: gate == controller.availableGates.last ? 0 : 12),
                child: Obx(() {
                  final isSelected = controller.selectedGate.value == gate;
                  return InkWell(
                    onTap: () => controller.selectGate(gate),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
                          width: isSelected ? 2 : 0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Gate $gate',
                        style: GoogleFonts.inter(
                          color: isSelected ? AppColors.primary : AppColors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildClassOption(TicketEntryController controller, VehicleClass vClass, String title, String subtitle) {
    return Obx(() {
      final isSelected = controller.selectedClass.value == vClass;
      return InkWell(
        onTap: () => controller.selectClass(vClass),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryContainer : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: isSelected ? AppColors.primary : AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRecentLogSection(TicketEntryController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppColors.muted, size: 16),
              const SizedBox(width: 8),
              Text(
                'RECENTLY ADDED',
                style: GoogleFonts.inter(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Obx(() {
            final DashboardController dashboardCtrl = Get.find<DashboardController>();
            final recentTickets = dashboardCtrl.allTickets.take(3).toList();

            if (recentTickets.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'NO RECENT ACTIVITY',
                  style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14),
                ),
              );
            }

            return Column(
              children: recentTickets.map((ticket) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildLogItem(ticket.formattedTimeIn, ticket.plate, ticket.zone),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogItem(String time, String plate, String zone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(time, style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14)),
        Text(plate, style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(zone, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildFooter(TicketEntryController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(color: AppColors.surfaceContainerLowest),
      child: Obx(() {
        final dashboardCtrl = Get.find<DashboardController>();
        final isGlobalFull = dashboardCtrl.availableSlots.value <= 0;
        final noZones = controller.availableZones.isEmpty;
        final isSubmitting = controller.isSubmitting.value;

        final isDisabled = isSubmitting || isGlobalFull || noZones;

        String buttonText = 'Issue Parking Ticket';
        if (isGlobalFull) buttonText = 'Facility At Max Capacity';
        else if (noZones) buttonText = 'All Zones Full';

        return Container(
          decoration: BoxDecoration(
            gradient: isDisabled ? null : const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
            ),
             color: isDisabled ? AppColors.surfaceContainerLow : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDisabled ? [] : const [
              BoxShadow(
                color: Color.fromRGBO(0, 83, 204, 0.4),
                blurRadius: 16,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: isDisabled ? null : controller.issueTicket,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: AppColors.surfaceContainerLowest,
              disabledForegroundColor: AppColors.surfaceContainerLowest, // It will use Text style for override
              minimumSize: const Size.fromHeight(64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: AppColors.surfaceContainerLowest, strokeWidth: 2),
                  )
                : Text(
                    buttonText,
                    style: GoogleFonts.inter(
                      color: isDisabled ? AppColors.danger : AppColors.surfaceContainerLowest,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
