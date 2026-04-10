// lib/modules/zone_setup/controllers/zone_setup_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../models/zone_setup_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';

class ZoneSetupController extends GetxController {
  final totalCapacityController = TextEditingController(text: '500');
  final totalCapacity = 500.obs;

  final zoneRows = <ZoneRowData>[].obs;
  final allocatedSpots = 0.obs;
  
  // Getter remains the same
  int get remainingSpots => totalCapacity.value - allocatedSpots.value;

  // --- Storage Key Constants ---
  static const String _storageKeyTotalCapacity = 'totalFacilityCapacity';
  static const String _storageKeyZones = 'configuredZones';
  static const String _storageKeyZoneCount = 'totalZonesCount';

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

  Future<void> armSystem() async {
    // 1. Validation A: Capacity Overload (Too many spots allocated)
    if (remainingSpots < 0) {
      _showSystemDialog(
        title: 'CAPACITY OVERLOAD',
        message: 'Allocated spots exceed total facility capacity. Reduce allocations by ${remainingSpots.abs()} before proceeding.',
        isError: true,
      );
      return;
    }

    // 2. Validation B: Incomplete Allocation (Not all spots assigned to a zone)
    if (remainingSpots > 0) {
      _showSystemDialog(
        title: 'INCOMPLETE ALLOCATION',
        message: 'There are still $remainingSpots unallocated spots. All physical capacity must be assigned to a zone before the system can be armed.',
        isError: true,
      );
      return;
    }

    // 3. Prepare the Zone Data for storage
    List<Map<String, dynamic>> serializedZones = zoneRows.map((row) => row.toJson()).toList();

    // 4. PERSISTENCE: Save ALL settings locally
    final box = GetStorage();
    await box.write(_storageKeyTotalCapacity, totalCapacity.value); 
    await box.write(_storageKeyZones, serializedZones);
    await box.write(_storageKeyZoneCount, serializedZones.length);

    // 5. Seamlessly route to the Review & Arm page
    Get.toNamed(Routes.REVIEW_ARM);
  }

  void returnToConfig() {
    Get.back();
  }

  // --- GLOBAL ACCESS HELPERS ---
  static int getTotalCapacity() {
    final box = GetStorage();
    return box.read(_storageKeyTotalCapacity) ?? 500; 
  }

  static List<Map<String, dynamic>> getConfiguredZones() {
    final box = GetStorage();
    List<dynamic>? storedZones = box.read(_storageKeyZones);
    
    if (storedZones != null && storedZones.isNotEmpty) {
      return storedZones.cast<Map<String, dynamic>>();
    }
    return [{'name': 'SYSTEM_ERR', 'capacity': getTotalCapacity(), 'occupied': 0}];
  }

  // --- CUSTOM SYSTEM DIALOG ---
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
          borderRadius: BorderRadius.zero, 
          side: BorderSide(color: borderColor.withOpacity(0.5), width: 2),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                message,
                style: GoogleFonts.ibmPlexMono(
                  color: AppColors.textMain,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); 
                    if (onAcknowledge != null) {
                      onAcknowledge(); 
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
      barrierDismissible: false,
    );
  }
}