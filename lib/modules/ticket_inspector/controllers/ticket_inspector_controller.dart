import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/models/ticket_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class TicketInspectorController extends GetxController {
  final TicketModel ticket;
  final isProcessing = false.obs;
  final double ratePerHour = 20.00;

  TicketInspectorController({required this.ticket});

  String get calculatedTotal {
    final parts = ticket.duration.split(':');
    if (parts.length == 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final totalHours = hours + (minutes / 60.0);
      final billableHours = totalHours < 1.0 ? 1.0 : totalHours;
      return 'P${(billableHours * ratePerHour).toStringAsFixed(2)}';
    }
    return 'P${ratePerHour.toStringAsFixed(2)}'; 
  }

  Future<void> processCheckout() async {
    isProcessing.value = true;
    await Future.delayed(const Duration(milliseconds: 800)); 
    
    // CONNECT TO DASHBOARD
    final dashboardCtrl = Get.find<DashboardController>();
    dashboardCtrl.checkoutTicket(ticket.id);
    
    isProcessing.value = false;
    Get.back(); // Closes modal
    
    Get.snackbar('CHECKOUT SUCCESSFUL', 'Vehicle ${ticket.plate} cleared. Gate barrier opening.', backgroundColor: AppColors.success.withOpacity(0.9), colorText: AppColors.backgroundDark, borderRadius: 0, margin: const EdgeInsets.all(16), icon: const Icon(Icons.check_circle, color: AppColors.backgroundDark));
  }
}