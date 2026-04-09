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
  final List<String> availableZones = [];

  @override
  void onInit() {
    super.onInit();
    // Pull the zones that were configured earlier
    availableZones.assignAll(dashboardCtrl.zones.map((z) => z.name).toList());
    if (availableZones.isNotEmpty) {
      selectedZone.value = availableZones.first;
    }
  }

  @override
  void onClose() {
    plateController.dispose();
    super.onClose();
  }

  void selectClass(VehicleClass vClass) => selectedClass.value = vClass;
  void selectZone(String zone) => selectedZone.value = zone;

  Future<void> issueTicket() async {
    final plate = plateController.text.trim();
    if (plate.isEmpty || selectedZone.value.isEmpty) {
      Get.snackbar('ERROR', 'Plate and Zone required.', backgroundColor: AppColors.danger, colorText: Colors.white, borderRadius: 0, margin: const EdgeInsets.all(16));
      return;
    }

    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    // Send to dashboard with the specific zone
    dashboardCtrl.addTicket(plate, selectedClass.value.name, selectedZone.value);

    isSubmitting.value = false;
    Get.back(); 
    Get.snackbar('ISSUED', 'Vehicle $plate logged to ${selectedZone.value}.', backgroundColor: AppColors.success, colorText: AppColors.backgroundDark, borderRadius: 0, margin: const EdgeInsets.all(16));
  }
}