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

  final gracePeriodCtrl = TextEditingController(text: '15');
  final baseHoursCtrl = TextEditingController(text: '2');
  final succeedingPeriodCtrl = TextEditingController(text: '1');
  final baseRateCtrl = TextEditingController(text: '20.0');
  final overstayRateCtrl = TextEditingController(text: '30.0');
  final overnightRateCtrl = TextEditingController(text: '150.0');

  final selectedScheduleType = 'twentyFourHours'.obs;

  final zoneRows = <ZoneRowData>[].obs;
  final allocatedSpots = 0.obs;
  
  // Getter remains the same
  int get remainingSpots => totalCapacity.value - allocatedSpots.value;

  // --- Storage Key Constants ---
  static const String _storageKeyTotalCapacity = 'totalFacilityCapacity';
  static const String _storageKeyZones = 'configuredZones';
  static const String _storageKeyZoneCount = 'totalZonesCount';
  static const String _storageKeyPricing = 'facilityPricingRules';

  @override
  void onInit() {
    super.onInit();
    totalCapacityController.addListener(_calculateTotals);
    
    List<dynamic>? storedZones = DatabaseService.getState(_storageKeyZones);
    if (storedZones != null && storedZones.isNotEmpty) {
      totalCapacityController.text = (DatabaseService.getState(_storageKeyTotalCapacity) ?? 500).toString();
      for (var z in storedZones) {
        _addZoneRow(z['name'].toString(), z['capacity'].toString());
      }
    } else {
      _addZoneRow('LEVEL_A', '200');
      _addZoneRow('LEVEL_B', '150');
    }

    final storedPricing = DatabaseService.getState(_storageKeyPricing);
    if (storedPricing != null) {
      gracePeriodCtrl.text = storedPricing['gracePeriod']?.toString() ?? '15';
      baseHoursCtrl.text = storedPricing['baseHours']?.toString() ?? '2';
      succeedingPeriodCtrl.text = storedPricing['succeedingPeriod']?.toString() ?? '1';
      baseRateCtrl.text = storedPricing['baseRate']?.toString() ?? '20.0';
      overstayRateCtrl.text = storedPricing['succeedingRate']?.toString() ?? '30.0';
      overnightRateCtrl.text = storedPricing['overnightRate']?.toString() ?? '150.0';
      
      if (storedPricing['scheduleType'] != null) {
        selectedScheduleType.value = storedPricing['scheduleType'];
      }
    }
  }

  @override
  void onClose() {
    totalCapacityController.dispose();
    gracePeriodCtrl.dispose();
    baseHoursCtrl.dispose();
    succeedingPeriodCtrl.dispose();
    baseRateCtrl.dispose();
    overstayRateCtrl.dispose();
    overnightRateCtrl.dispose();
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
    if (remainingSpots < 0) {
      AerostaticDialog.show(
        title: 'CAPACITY OVERLOAD',
        message: 'Allocated spots exceed total facility capacity. Reduce allocations by ${remainingSpots.abs()} before proceeding.',
        isError: true,
      );
      return;
    }

    if (remainingSpots > 0) {
      AerostaticDialog.show(
        title: 'INCOMPLETE ALLOCATION',
        message: 'There are still $remainingSpots unallocated spots. All physical capacity must be assigned to a zone before the system can be armed.',
        isError: true,
      );
      return;
    }

    List<Map<String, dynamic>> serializedZones = zoneRows.map((row) => row.toJson()).toList();

    // Bundle our new pricing logic
    Map<String, dynamic> pricingData = {
      'scheduleType': selectedScheduleType.value,
      'gracePeriod': int.tryParse(gracePeriodCtrl.text) ?? 15,
      'baseHours': int.tryParse(baseHoursCtrl.text) ?? 2,
      'succeedingPeriod': int.tryParse(succeedingPeriodCtrl.text) ?? 1,
      'baseRate': double.tryParse(baseRateCtrl.text) ?? 20.0,
      'succeedingRate': double.tryParse(overstayRateCtrl.text) ?? 30.0,
      'overnightRate': double.tryParse(overnightRateCtrl.text) ?? 150.0,
    };

    await DatabaseService.saveState(_storageKeyTotalCapacity, totalCapacity.value); 
    await DatabaseService.saveState(_storageKeyZones, serializedZones);
    await DatabaseService.saveState(_storageKeyZoneCount, serializedZones.length);
    await DatabaseService.saveState(_storageKeyPricing, pricingData);

    Get.toNamed(Routes.REVIEW_ARM);
  }

  void returnToConfig() {
    Get.offNamed(Routes.CONFIG_SETUP);
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

  static Map<String, dynamic> getPricingRules() {
    final storedPricing = DatabaseService.getState(_storageKeyPricing);
    if (storedPricing != null && storedPricing is Map<String, dynamic>) {
      return storedPricing;
    }
    return {
      'gracePeriod': 15,
      'baseRate': 20.0,
      'succeedingRate': 30.0,
      'overnightRate': 150.0,
    };
  }
}