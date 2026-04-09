import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
// ADDED: Import Dashboard Controller
import '../../dashboard/controllers/dashboard_controller.dart'; 

enum VehicleClass { car, truck, moto }

class TicketEntryController extends GetxController {
  final plateController = TextEditingController();
  final selectedClass = VehicleClass.car.obs;
  final isSubmitting = false.obs;

  @override
  void onClose() {
    plateController.dispose();
    super.onClose();
  }

  void selectClass(VehicleClass vClass) {
    selectedClass.value = vClass;
  }

  Future<void> issueTicket() async {
    final plate = plateController.text.trim();
    
    if (plate.isEmpty) {
      Get.snackbar(
        'VALIDATION ERROR', 'License Plate is required.',
        backgroundColor: AppColors.danger.withOpacity(0.9),
        colorText: Colors.white, borderRadius: 0, margin: const EdgeInsets.all(16),
      );
      return;
    }

    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    // CHANGED: Send the ticket to the Dashboard!
    final dashboardCtrl = Get.find<DashboardController>();
    dashboardCtrl.addTicket(plate, selectedClass.value.name);

    isSubmitting.value = false;
    Get.back(); // Closes the drawer
    
    Get.snackbar(
      'TICKET ISSUED', 'Vehicle $plate has been logged successfully.',
      backgroundColor: AppColors.success.withOpacity(0.9),
      colorText: AppColors.backgroundDark, borderRadius: 0, margin: const EdgeInsets.all(16),
    );
  }
}