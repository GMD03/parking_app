import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/ticket_entry_controller.dart';

class TicketEntryView extends GetView<TicketEntryController> {
  const TicketEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    // We use Material and Align to make this act as a right-side drawer
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
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
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLicensePlateInput(),
                      const SizedBox(height: 32),
                      _buildVehicleClassSelector(),
                      const SizedBox(height: 48),
                      _buildSessionLog(),
                    ],
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'CREATE_TICKET',
            style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 2),
          ),
          IconButton(
            icon: const Text('[ X ]'),
            onPressed: () => Get.back(),
            color: AppColors.muted,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            style: IconButton.styleFrom(
              foregroundColor: AppColors.muted,
            ).copyWith(
              foregroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.hovered) ? AppColors.primary : AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicensePlateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LICENSE PLATE', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12, letterSpacing: 1.5)),
            Text('AUTO-FOCUS', style: GoogleFonts.ibmPlexMono(color: AppColors.primary.withOpacity(0.7), fontSize: 10)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.plateController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.ibmPlexMono(color: Colors.white, fontSize: 28),
          onSubmitted: (_) => controller.issueTicket(),
          decoration: InputDecoration(
            hintText: 'ENTER PLATE...',
            hintStyle: GoogleFonts.ibmPlexMono(color: AppColors.border),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            filled: true,
            fillColor: AppColors.backgroundDark,
            enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10),
              children: [
                const TextSpan(text: 'PRESS '),
                WidgetSpan(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(color: AppColors.backgroundDark, border: Border.all(color: AppColors.border)),
                    child: const Text('ENTER', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                  ),
                ),
                const TextSpan(text: ' TO SUBMIT'),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildVehicleClassSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VEHICLE CLASS', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Container(
          height: 56,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(child: _buildClassOption('CAR', VehicleClass.car)),
              Expanded(child: _buildClassOption('TRUCK', VehicleClass.truck)),
              Expanded(child: _buildClassOption('MOTO', VehicleClass.moto)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassOption(String label, VehicleClass vClass) {
    return Obx(() {
      final isSelected = controller.selectedClass.value == vClass;
      return InkWell(
        onTap: () => controller.selectClass(vClass),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.ibmPlexMono(
                color: isSelected ? AppColors.primary : AppColors.muted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSessionLog() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Text('SESSION LOG', style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10, letterSpacing: 1.5)),
          ),
          _buildLogEntry('14:31:22', 'XYZ-987'),
          const SizedBox(height: 8),
          _buildLogEntry('14:28:05', 'ABC-123'),
        ],
      ),
    );
  }

  Widget _buildLogEntry(String time, String plate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(time, style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12)),
        Text(plate, style: GoogleFonts.ibmPlexMono(color: Colors.white, fontSize: 12)),
        Text('LOGGED', style: GoogleFonts.ibmPlexMono(color: AppColors.success, fontSize: 12)),
      ],
    );
  }

  Widget _buildFooter() {
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
            : Text('[ ISSUE TICKET ]', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5)),
      )),
    );
  }
}