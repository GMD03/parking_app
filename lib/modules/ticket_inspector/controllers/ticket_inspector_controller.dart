import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; 
import '../../../core/theme/app_colors.dart';
import '../../dashboard/models/ticket_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../core/services/database_service.dart';
import '../../../core/utils/billing_engine.dart';
import '../../../core/models/pricing_config.dart';

class TicketInspectorController extends GetxController {
  final TicketModel ticket;
  final DashboardController dashboardCtrl = Get.find<DashboardController>();
  
  final isProcessing = false.obs;
  final double ratePerHour = 20.00;

  final availableGates = <String>['1', '2'];
  final selectedGate = '1'.obs;

  TicketInspectorController({required this.ticket}) {
    if (ticket.gate != null && availableGates.contains(ticket.gate)) {
      selectedGate.value = ticket.gate!;
    }
  }

  void selectGate(String gate) => selectedGate.value = gate;

  String get liveDuration {
    dashboardCtrl.currentTime.value;
    return ticket.currentDuration;
  }

  String get calculatedTotal {
    dashboardCtrl.currentTime.value; 
    final end = ticket.timeOut ?? DateTime.now();
    
    // Fetch live configurations
    final storedPricing = DatabaseService.getState('facilityPricingRules');
    final config = PricingConfig.default24Hour();
    
    if (storedPricing != null) {
      if (storedPricing['scheduleType'] != null) {
        config.scheduleType = ScheduleType.values.firstWhere(
          (e) => e.name == storedPricing['scheduleType'],
          orElse: () => ScheduleType.twentyFourHours,
        );
      }
      config.gracePeriodMinutes = storedPricing['gracePeriod'] as int? ?? 15;
      config.baseHours = storedPricing['baseHours'] as int? ?? config.baseHours;
      config.succeedingPeriod = storedPricing['succeedingPeriod'] as int? ?? config.succeedingPeriod;
      config.baseRate = (storedPricing['baseRate'] as num?)?.toDouble() ?? 20.0;
      config.succeedingRate = (storedPricing['succeedingRate'] as num?)?.toDouble() ?? 30.0;
      config.overnightRate = (storedPricing['overnightRate'] as num?)?.toDouble() ?? 150.0;
    }
    
    final due = BillingEngine.calculateDue(ticket.timeIn, end, config);
    return 'P${due.toStringAsFixed(2)}';
  }

  Future<void> processCheckout() async {
    isProcessing.value = true;
    
    dashboardCtrl.initiateCheckout(ticket.id);
    
    await Future.delayed(const Duration(milliseconds: 800)); 
    
    try {
      final url = Uri.parse('http://127.0.0.1:8088/open/EXIT/${selectedGate.value}'); 
      
      await http.post(url).timeout(const Duration(seconds: 2)); 
      print("SUCCESS: Command sent to Python hardware script for Gate ${selectedGate.value}!");
    } catch (e) {
      print("WARNING: Hardware disconnected or Python script offline. $e");
    }

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