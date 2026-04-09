import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for SCADA typography
import '../models/zone_setup_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';

class ZoneSetupController extends GetxController {
  final totalCapacityController = TextEditingController(text: '500');
  final totalCapacity = 500.obs;

  final zoneRows = <ZoneRowData>[].obs;
  final allocatedSpots = 0.obs;
  int get remainingSpots => totalCapacity.value - allocatedSpots.value;

  @override
  void onInit() {
    super.onInit();
    totalCapacityController.addListener(_calculateTotals);
    _addZoneRow('LEVEL_A', '200');
    _addZoneRow('LEVEL_B', '150');
  }

  @override
  void onClose() {
    totalCapacityController.dispose();
    for (var row in zoneRows) {
      row.dispose();
    }
    super.onClose();
  }

  void _addZoneRow(String name, String spots) {
    final newRow = ZoneRowData(name: name, spots: spots);
    newRow.spotsController.addListener(_calculateTotals);
    zoneRows.add(newRow);
    _calculateTotals();
  }

  void addNewZone() => _addZoneRow('NEW_ZONE', '0');

  void removeZone(int index) {
    final row = zoneRows[index];
    row.spotsController.removeListener(_calculateTotals);
    row.dispose();
    zoneRows.removeAt(index);
    _calculateTotals();
  }

  void _calculateTotals() {
    totalCapacity.value = int.tryParse(totalCapacityController.text) ?? 0;
    int currentAllocated = 0;
    for (var row in zoneRows) {
      currentAllocated += int.tryParse(row.spotsController.text) ?? 0;
    }
    allocatedSpots.value = currentAllocated;
  }

  void armSystem() {
    if (remainingSpots < 0) {
      Get.snackbar('CAPACITY_OVERLOAD', 'Allocated spots exceed total facility capacity.', backgroundColor: AppColors.danger, colorText: Colors.white, borderRadius: 0, margin: const EdgeInsets.all(16));
      return;
    }

    // Bundle the zones and capacity
    final zoneData = zoneRows.map((row) => {
      'name': row.nameController.text.trim().isEmpty ? 'UNNAMED' : row.nameController.text.trim().toUpperCase(),
      'capacity': int.tryParse(row.spotsController.text) ?? 0,
    }).toList();

    final setupData = {
      'totalCapacity': totalCapacity.value,
      'zones': zoneData,
    };

    Get.snackbar('SYSTEM_ARMED', 'Parking system successfully initialized and armed.', backgroundColor: AppColors.success, colorText: AppColors.backgroundDark, borderRadius: 0, margin: const EdgeInsets.all(16));
    
    // Send data to the dashboard!
    Get.offAllNamed('/review-arm', arguments: setupData);
  }
  

  // -----------------------------------------------------------------
  // CUSTOM SYSTEM DIALOG (POP-UP)
  // -----------------------------------------------------------------
  void _showSystemDialog({
    required String title,
    required String message,
    required bool isError,
    VoidCallback? onAcknowledge,
  }) {
    final Color bgColor = AppColors.surface; 
    final Color borderColor = isError ? AppColors.danger : AppColors.success;
    final Color textColor = isError ? Colors.white : AppColors.backgroundDark;

    Get.dialog(
      Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Sharp SCADA edges
          side: BorderSide(color: borderColor.withOpacity(0.5), width: 2),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Icon(
                    isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: borderColor,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.ibmPlexSans(
                        color: borderColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
              
              // Message Body
              Text(
                message,
                style: GoogleFonts.ibmPlexMono(
                  color: AppColors.textMain,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close the dialog
                    if (onAcknowledge != null) {
                      onAcknowledge(); // Execute routing if provided
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: borderColor,
                    foregroundColor: textColor,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: Text(
                    '[ ACKNOWLEDGE ]',
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // Forces the user to click the acknowledge button
    );
  }
}