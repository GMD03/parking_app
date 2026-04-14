// lib/modules/dashboard/models/ticket_model.dart
import '../../../core/models/pricing_config.dart';
import '../../../core/utils/billing_engine.dart';
import '../../../core/services/database_service.dart';

enum TicketStatus { active, overstay, processing }

class TicketModel {
  final String id;
  final String plate;
  final DateTime timeIn;
  DateTime? timeOut;
  final String zone;
  final String vehicleClass;
  final String? gate;
  TicketStatus status;

  TicketModel({
    required this.id,
    required this.plate,
    required this.timeIn,
    this.timeOut,
    required this.zone,
    required this.status,
    required this.vehicleClass,
    this.gate,
  });

  // Helper method to format time for the UI
  String get formattedTimeIn {
    return "${timeIn.hour.toString().padLeft(2, '0')}:${timeIn.minute.toString().padLeft(2, '0')}:${timeIn.second.toString().padLeft(2, '0')}";
  }

  // Helper method to calculate live duration
  String get currentDuration {
    final endTime = timeOut ?? DateTime.now();
    final difference = endTime.difference(timeIn);
    
    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    
    return "$hours:$minutes:$seconds";
  }

  // NEW: Helper method to calculate total due dynamically via BillingEngine
  double get totalDue {
    final endTime = timeOut ?? DateTime.now();
    
    // Using the 24 hour default configuration as the primary engine rule
    final config = PricingConfig.default24Hour(); 
    
    // Fetch live configurations to ensure dashboard consistency
    final storedPricing = DatabaseService.getState('facilityPricingRules');
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
    
    return BillingEngine.calculateDue(timeIn, endTime, config);
  }

  // --- Persistence Methods ---
  Map<String, dynamic> toJson() => {
    'id': id,
    'plate': plate,
    'timeIn': timeIn.toIso8601String(),
    'timeOut': timeOut?.toIso8601String(),
    'zone': zone,
    'vehicleClass': vehicleClass,
    'status': status.name,
    'gate': gate,
  };

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
    id: json['id'],
    plate: json['plate'],
    timeIn: DateTime.parse(json['timeIn']),
    timeOut: json['timeOut'] != null ? DateTime.parse(json['timeOut']) : null,
    zone: json['zone'],
    vehicleClass: json['vehicleClass'] ?? 'UNKNOWN',
    gate: json['gate'],
    
    status: TicketStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => TicketStatus.active,
    ),
  );
}