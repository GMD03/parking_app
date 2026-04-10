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

  // CHANGED: Calculate cost using actual Duration difference, not strings!
  String get calculatedTotal {
    final endTime = ticket.timeOut ?? DateTime.now();
    final difference = endTime.difference(ticket.timeIn);
    
    // Convert duration to total decimal hours
    final totalHours = difference.inMinutes / 60.0;
    
    // Minimum 1 hour charge
    final billableHours = totalHours < 1.0 ? 1.0 : totalHours;
    
    return 'P${(billableHours * ratePerHour).toStringAsFixed(2)}';
  }

  Future<void> processCheckout() async {
    isProcessing.value = true;
    
    final dashboardCtrl = Get.find<DashboardController>();
    
    // 1. Freeze the ticket duration and mark as processing
    dashboardCtrl.initiateCheckout(ticket.id);
    
    // Simulate payment gateway handshake
    await Future.delayed(const Duration(milliseconds: 1200)); 
    
    // 2. Finalize checkout and remove from dashboard
    dashboardCtrl.finalizeCheckout(ticket.id);
    
    isProcessing.value = false;
    Get.back(); // Closes modal
    
    Get.snackbar(
      'CHECKOUT SUCCESSFUL', 
      'Ticket ${ticket.id} cleared from local buffer.', 
      backgroundColor: AppColors.success, 
      colorText: AppColors.backgroundDark, 
      borderRadius: 0, 
      margin: const EdgeInsets.all(16)
    );
  }
}