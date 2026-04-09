import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/ticket_entry_controller.dart';

// CHANGED: From GetView<TicketEntryController> to StatelessWidget
class TicketEntryView extends StatelessWidget {
  const TicketEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        // THE FIX: GetBuilder handles init and dispose safely synced with the widget lifecycle
        child: GetBuilder<TicketEntryController>(
          init: TicketEntryController(), 
          builder: (controller) {
            return Container(
              width: 400,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(left: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(-10, 0)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(controller),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLicensePlateInput(controller),
                          const SizedBox(height: 32),
                          _buildVehicleClassSelector(controller),
                          const SizedBox(height: 32),
                          _buildRecentLogSection(),
                        ],
                      ),
                    ),
                  ),
                  
                  _buildFooter(controller),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildHeader(TicketEntryController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEW ENTRY LOG', style: GoogleFonts.ibmPlexSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text('MANUAL OVERRIDE', style: GoogleFonts.ibmPlexMono(color: AppColors.primary, fontSize: 10, letterSpacing: 2)),
            ],
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: AppColors.muted, size: 20),
            splashRadius: 24,
            hoverColor: AppColors.danger.withOpacity(0.1),
          )
        ],
      ),
    );
  }

  Widget _buildLicensePlateInput(TicketEntryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: AppColors.textMain, size: 14),
            const SizedBox(width: 8),
            Text('LICENSE PLATE', style: GoogleFonts.ibmPlexSans(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.plateController,
          autofocus: true,
          style: GoogleFonts.ibmPlexMono(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundDark,
            hintText: 'ENTER PLATE...',
            hintStyle: GoogleFonts.ibmPlexMono(color: AppColors.border, fontSize: 18, letterSpacing: 2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.border.withOpacity(0.5))),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleClassSelector(TicketEntryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VEHICLE CLASSIFICATION', style: GoogleFonts.ibmPlexSans(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildClassOption(controller, VehicleClass.car, 'CLASS A', 'SEDAN/SUV')),
            const SizedBox(width: 12),
            Expanded(child: _buildClassOption(controller, VehicleClass.truck, 'CLASS B', 'TRUCK/VAN')),
          ],
        ),
        const SizedBox(height: 12),
        _buildClassOption(controller, VehicleClass.moto, 'CLASS C', 'MOTORCYCLE'),
      ],
    );
  }

  Widget _buildClassOption(TicketEntryController controller, VehicleClass vClass, String title, String subtitle) {
    return Obx(() {
      final isSelected = controller.selectedClass.value == vClass;
      return InkWell(
        onTap: () => controller.selectClass(vClass),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.backgroundDark,
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.ibmPlexSans(color: isSelected ? AppColors.primary : AppColors.textMain, fontSize: 12, fontWeight: FontWeight.bold)),
                  if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                ],
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRecentLogSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppColors.muted, size: 14),
              const SizedBox(width: 8),
              Text('LOCAL BUFFER', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 12),
          _buildLogItem('14:32:05', 'XYZ-9876'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.border, height: 1)),
          _buildLogItem('14:31:12', 'ABC-1234'),
        ],
      ),
    );
  }

  Widget _buildLogItem(String time, String plate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(time, style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12)),
        Text(plate, style: GoogleFonts.ibmPlexMono(color: Colors.white, fontSize: 12)),
        Text('LOGGED', style: GoogleFonts.ibmPlexMono(color: AppColors.success, fontSize: 12)),
      ],
    );
  }

  Widget _buildFooter(TicketEntryController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Obx(() => ElevatedButton(
        onPressed: controller.isSubmitting.value ? null : controller.issueTicket,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          foregroundColor: AppColors.backgroundDark,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
        child: controller.isSubmitting.value
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.backgroundDark, strokeWidth: 2))
            : Text('[ ISSUE PARKING TICKET ]', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5)),
      )),
    );
  }
}