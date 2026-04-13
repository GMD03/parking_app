import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/models/ticket_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class TicketInspectorController extends GetxController {
  final TicketModel ticket;
  final DashboardController dashboardCtrl = Get.find<DashboardController>();
  
  final isProcessing = false.obs;
  final double ratePerHour = 20.00;

  TicketInspectorController({required this.ticket});

  // --- THE FIX: REACTIVITY TRIGGERS ---
  // By reading 'dashboardCtrl.currentTime.value', we tell GetX to redraw this data every time the dashboard clock ticks!
  
  String get liveDuration {
    dashboardCtrl.currentTime.value;
    return ticket.currentDuration;
  }

  String get calculatedTotal {
    dashboardCtrl.currentTime.value; 
    
    final end = ticket.timeOut ?? DateTime.now();
    final diff = end.difference(ticket.timeIn);
    
    final totalHours = diff.inMinutes / 60.0;
    final billableHours = totalHours < 1.0 ? 1.0 : totalHours; // Minimum 1 hr charge
    return 'P${(billableHours * ratePerHour).toStringAsFixed(2)}';
  }

  Future<void> processCheckout() async {
    isProcessing.value = true;
    
    dashboardCtrl.initiateCheckout(ticket.id);
    
    await Future.delayed(const Duration(milliseconds: 800)); 
    
    dashboardCtrl.finalizeCheckout(ticket.id);
    
    isProcessing.value = false;
    Get.back(); 
    
    Get.snackbar(
      'CHECKOUT SUCCESSFUL', 'Vehicle ${ticket.plate} cleared. Gate barrier opening.', 
      backgroundColor: AppColors.success.withOpacity(0.9), 
      colorText: AppColors.backgroundDark, 
      borderRadius: 0, 
      margin: const EdgeInsets.all(16), 
      icon: const Icon(Icons.check_circle, color: AppColors.backgroundDark)
    );
  }
}