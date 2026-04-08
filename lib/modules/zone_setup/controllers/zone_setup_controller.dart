import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/zone_setup_model.dart';
import '../../../core/theme/app_colors.dart';

class ZoneSetupController extends GetxController {
  // Total Capacity Input
  final totalCapacityController = TextEditingController(text: '500');
  final totalCapacity = 500.obs;

  // Dynamic list of Zone Rows
  final zoneRows = <ZoneRowData>[].obs;
  
  // Computed values
  final allocatedSpots = 0.obs;
  int get remainingSpots => totalCapacity.value - allocatedSpots.value;

  @override
  void onInit() {
    super.onInit();
    
    // Listen to Total Capacity changes
    totalCapacityController.addListener(_calculateTotals);

    // Initialize with default zones from the PRD
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
    // Add listener to recalculate when spots change
    newRow.spotsController.addListener(_calculateTotals);
    zoneRows.add(newRow);
    _calculateTotals();
  }

  void addNewZone() {
    _addZoneRow('NEW_ZONE', '0');
  }

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
      Get.snackbar(
        'CAPACITY_OVERLOAD',
        'Allocated spots exceed total facility capacity.',
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        borderRadius: 0,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return;
    }

    Get.snackbar(
      'SYSTEM_ARMED',
      'Parking system successfully initialized and armed.',
      backgroundColor: AppColors.success,
      colorText: AppColors.backgroundDark,
      borderRadius: 0,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle_outline, color: AppColors.backgroundDark),
    );
    
    // TODO: Route to Main Dashboard
    // Get.offAllNamed(Routes.DASHBOARD);
  }

  void returnToConfig() {
    Get.back();
  }
}