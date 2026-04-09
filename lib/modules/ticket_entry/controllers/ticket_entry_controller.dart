import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/controllers/dashboard_controller.dart'; 

enum VehicleClass { car, truck, moto }

class TicketEntryController extends GetxController {
  final plateController = TextEditingController();
  final selectedClass = VehicleClass.car.obs;
  final isSubmitting = false.obs;

  // NEW: Zone Selection Variables
  final availableZones = <String>[].obs;
  final selectedZone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAvailableZones();
  }

  // NEW: Pull the active zones from the Dashboard Controller
  void _loadAvailableZones() {
    try {
      final dashboardCtrl = Get.find<DashboardController>();
      if (dashboardCtrl.zones.isNotEmpty) {
        availableZones.value = dashboardCtrl.zones.map((z) => z.name).toList();
        selectedZone.value = availableZones.first; // Default to the first zone
      } else {
        availableZones.add('DEFAULT_ZONE');
        selectedZone.value = 'DEFAULT_ZONE';
      }
    } catch (e) {
      // Fallback if Dashboard isn't found for some reason
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
  
  // NEW: Method for the UI to update the selected zone
  void selectZone(String zoneName) => selectedZone.value = zoneName;

  Future<void> issueTicket() async {
    final plate = plateController.text.trim();
    
    if (plate.isEmpty) {
      Get.snackbar(
        'VALIDATION ERROR', 
        'License Plate is required.', 
        backgroundColor: AppColors.danger.withOpacity(0.9), 
        colorText: Colors.white, 
        borderRadius: 0.0, 
        margin: const EdgeInsets.all(16)
      );
      return;
    }

    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    // CONNECT TO DASHBOARD AND PASS THE ZONE
    final dashboardCtrl = Get.find<DashboardController>();
    // Note: We are passing the selected zone here. We will need to update
    // the DashboardController's addTicket method slightly to accept this.
    dashboardCtrl.addTicket(plate, selectedClass.value.name, selectedZone.value);

    isSubmitting.value = false;
    Get.back(); // Closes drawer
    
    Get.snackbar(
      'TICKET ISSUED', 
      'Entry logged successfully.',
      backgroundColor: AppColors.success,
      colorText: AppColors.backgroundDark,
      borderRadius: 0.0,
      margin: const EdgeInsets.all(16)
    );
  }
}