// lib/modules/ticket_entry/controllers/ticket_entry_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../core/widgets/aerostatic_dialog.dart';

enum VehicleClass { car, truck, moto }

class TicketEntryController extends GetxController {
  final plateController = TextEditingController();
  final selectedClass = VehicleClass.car.obs;
  final isSubmitting = false.obs;

  final availableZones = <String>[].obs;
  final selectedZone = ''.obs;

  final availableGates = <String>['1', '2'];
  final selectedGate = '1'.obs;

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
  void selectGate(String gate) => selectedGate.value = gate;

  Future<void> issueTicket() async {
    final dashboardCtrl = Get.find<DashboardController>();

    // GLOBAL CAPACITY CHECK: Deny entry if overall lot is full
    if (dashboardCtrl.availableSlots.value <= 0) {
      AerostaticDialog.toast(
        title: 'PARKING FULL',
        message: 'Cannot issue ticket. No available slots in the facility.',
        isError: true,
      );
      return;
    }

    // ZONE CHECK: Deny entry if no valid zones are selected/available
    if (selectedZone.value.isEmpty) {
      AerostaticDialog.toast(
        title: 'NO ZONE AVAILABLE',
        message: 'All configured zones are currently at maximum capacity.',
        isError: true,
      );
      return;
    }

    final plate = plateController.text.trim();

    if (plate.isEmpty) {
      AerostaticDialog.toast(
        title: 'VALIDATION ERROR',
        message: 'License Plate is required.',
        isError: true,
      );
      return;
    }

    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    dashboardCtrl.addTicket(
      plate,
      selectedClass.value.name,
      selectedZone.value,
      selectedGate.value,
    );

    try {
      final url = Uri.parse('http://127.0.0.1:8088/open/ENTRY/${selectedGate.value}'); 
      await http.post(url).timeout(const Duration(seconds: 2)); 
      print("SUCCESS: Entry command sent to Python hardware script for Gate ${selectedGate.value}!");
    } catch (e) {
      print("WARNING: Hardware disconnected or Python script offline. $e");
    }

    isSubmitting.value = false;
    Get.back(); // Closes drawer

    AerostaticDialog.toast(
      title: 'TICKET ISSUED',
      message: 'Entry logged successfully.',
    );
  }
}
