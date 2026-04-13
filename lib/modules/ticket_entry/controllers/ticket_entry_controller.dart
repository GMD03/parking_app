// lib/modules/ticket_entry/controllers/ticket_entry_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

enum VehicleClass { car, truck, moto }

class TicketEntryController extends GetxController {
  final plateController = TextEditingController();
  final selectedClass = VehicleClass.car.obs;
  final isSubmitting = false.obs;

  final availableZones = <String>[].obs;
  final selectedZone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAvailableZones();
  }

  void _loadAvailableZones() {
    try {
      final dashboardCtrl = Get.find<DashboardController>();

      // LOGIC UPDATE: Filter zones to only include those that are NOT full
      final activeZones = dashboardCtrl.zones
          .where((z) => z.occupied < z.capacity)
          .toList();

      if (activeZones.isNotEmpty) {
        availableZones.value = activeZones.map((z) => z.name).toList();
        selectedZone.value =
            availableZones.first; // Default to the first available zone
      } else {
        availableZones.clear();
        selectedZone.value = ''; // Clear selection if all are full
      }
    } catch (e) {
      availableZones.add('DEFAULT_ZONE');
      selectedZone.value = 'DEFAULT_ZONE';
    }
  }

  @override
  void onClose() {
    plateController.dispose();
    super.onClose();
  }

  void selectClass(VehicleClass vClass) => selectedClass.value = vClass;
  void selectZone(String zoneName) => selectedZone.value = zoneName;

  Future<void> issueTicket() async {
    final dashboardCtrl = Get.find<DashboardController>();

    // GLOBAL CAPACITY CHECK: Deny entry if overall lot is full
    if (dashboardCtrl.availableSlots.value <= 0) {
      Get.snackbar(
        'PARKING FULL',
        'Cannot issue ticket. No available slots in the facility.',
        backgroundColor: AppColors.danger.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 0.0,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // ZONE CHECK: Deny entry if no valid zones are selected/available
    if (selectedZone.value.isEmpty) {
      Get.snackbar(
        'NO ZONE AVAILABLE',
        'All configured zones are currently at maximum capacity.',
        backgroundColor: AppColors.danger.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 0.0,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final plate = plateController.text.trim();

    if (plate.isEmpty) {
      Get.snackbar(
        'VALIDATION ERROR',
        'License Plate is required.',
        backgroundColor: AppColors.danger.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 0.0,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    dashboardCtrl.addTicket(
      plate,
      selectedClass.value.name,
      selectedZone.value,
    );

    isSubmitting.value = false;
    Get.back(); // Closes drawer

    Get.snackbar(
      'TICKET ISSUED',
      'Entry logged successfully.',
      backgroundColor: AppColors.success,
      colorText: AppColors.backgroundDark,
      borderRadius: 0.0,
      margin: const EdgeInsets.all(16),
    );
  }
}
