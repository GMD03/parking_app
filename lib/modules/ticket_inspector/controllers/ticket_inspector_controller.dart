import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/models/ticket_model.dart';

class TicketInspectorController extends GetxController {
  final TicketModel ticket;
  final isProcessing = false.obs;

  // Pricing constants
  final double ratePerHour = 20.00;

  TicketInspectorController({required this.ticket});

  // Dummy calculation for UI purposes
  String get calculatedTotal {
    // In a real app, you'd parse the duration string and calculate based on hours.
    // For this UI mockup based on the HTML, we'll just return a static formatted string
    // or calculate a rough estimate based on the dummy duration string (e.g., "05:50:00").
    return 'P35.00'; 
  }

  Future<void> processCheckout() async {
    isProcessing.value = true;
    
    // Simulate API call to process payment / close ticket
    await Future.delayed(const Duration(seconds: 1));
    
    isProcessing.value = false;
    Get.back(); // Close dialog
    
    Get.snackbar(
      'CHECKOUT SUCCESSFUL',
      'Vehicle ${ticket.plate} cleared. Gate barrier opening.',
      backgroundColor: AppColors.success.withOpacity(0.9),
      colorText: AppColors.backgroundDark,
      borderRadius: 0,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: AppColors.backgroundDark),
    );
  }
}