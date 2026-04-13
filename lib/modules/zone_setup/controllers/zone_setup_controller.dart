// lib/modules/zone_setup/controllers/zone_setup_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../models/zone_setup_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/aerostatic_dialog.dart';

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
      AerostaticDialog.show(
        title: 'CAPACITY OVERLOAD',
        message: 'Allocated spots exceed total facility capacity. Reduce allocations by ${remainingSpots.abs()} before proceeding.',
        isError: true,
      );
      return;
    }

    // 2. Validation B: Incomplete Allocation (Not all spots assigned to a zone)
    if (remainingSpots > 0) {
      AerostaticDialog.show(
        title: 'INCOMPLETE ALLOCATION',
        message: 'There are still $remainingSpots unallocated spots. All physical capacity must be assigned to a zone before the system can be armed.',
        isError: true,
      );
      return;
    }

    // 3. Prepare the Zone Data for storage
    List<Map<String, dynamic>> serializedZones = zoneRows.map((row) => row.toJson()).toList();

    // 4. PERSISTENCE: Save ALL settings locally
    await DatabaseService.saveState(_storageKeyTotalCapacity, totalCapacity.value); 
    await DatabaseService.saveState(_storageKeyZones, serializedZones);
    await DatabaseService.saveState(_storageKeyZoneCount, serializedZones.length);

    // 5. Seamlessly route to the Review & Arm page
    Get.toNamed(Routes.REVIEW_ARM);
  }

  void returnToConfig() {
    Get.back();
  }

  // --- GLOBAL ACCESS HELPERS ---
  static int getTotalCapacity() {
    return DatabaseService.getState(_storageKeyTotalCapacity) ?? 500; 
  }

  static List<Map<String, dynamic>> getConfiguredZones() {
    List<dynamic>? storedZones = DatabaseService.getState(_storageKeyZones);
    
    if (storedZones != null && storedZones.isNotEmpty) {
      return storedZones.cast<Map<String, dynamic>>();
    }
    return [{'name': 'SYSTEM_ERR', 'capacity': getTotalCapacity(), 'occupied': 0}];
  }

  // Dialog removed
}