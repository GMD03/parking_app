import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/controllers/dashboard_controller.dart'; 

enum VehicleClass { car, truck, moto }

class TicketEntryController extends GetxController {
  final plateController = TextEditingController();
  final selectedClass = VehicleClass.car.obs;
  final isSubmitting = false.obs;

  final dashboardCtrl = Get.find<DashboardController>();
  final RxString selectedZone = ''.obs;
  final RxList<String> availableZones = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Grab zones from dashboard
    availableZones.assignAll(dashboardCtrl.zones.map((z) => z.name).toList());
    if (availableZones.isNotEmpty) selectedZone.value = availableZones.first;
  }

  @override
  void onClose() {
    plateController.dispose();
    super.onClose();
  }

  void selectClass(VehicleClass vClass) => selectedClass.value = vClass;
  void selectZone(String? zone) { if (zone != null) selectedZone.value = zone; }

  Future<void> issueTicket() async {
    final plate = plateController.text.trim();
    
    if (plate.isEmpty || selectedZone.value.isEmpty) {
      Get.snackbar('VALIDATION ERROR', 'License Plate and Zone are required.', backgroundColor: AppColors.danger, colorText: Colors.white, borderRadius: 0, margin: const EdgeInsets.all(16));
      return;
    }

    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    // Send the ticket TO THE DASHBOARD!
    dashboardCtrl.addTicket(plate, selectedClass.value.name, selectedZone.value);

    isSubmitting.value = false;
    Get.back(); // Closes the drawer
    Get.snackbar('TICKET ISSUED', 'Vehicle $plate assigned to ${selectedZone.value}.', backgroundColor: AppColors.success, colorText: AppColors.backgroundDark, borderRadius: 0, margin: const EdgeInsets.all(16));
  }
}