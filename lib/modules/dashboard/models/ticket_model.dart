// lib/modules/dashboard/models/ticket_model.dart

enum TicketStatus { active, overstay, processing }

class TicketModel {
  final String id;
  final String plate;
  final DateTime timeIn;
  DateTime? timeOut;
  final String zone;
  TicketStatus status;

  TicketModel({
    required this.id,
    required this.plate,
    required this.timeIn,
    this.timeOut,
    required this.zone,
    required this.status,
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

  // NEW: Helper method to calculate total due dynamically
  double get totalDue {
    final endTime = timeOut ?? DateTime.now();
    final difference = endTime.difference(timeIn);
    
    // Example Pricing Logic (Feel free to adjust the rates)
    double baseRate = 50.0; // Flat rate for the first 2 hours
    double hourlyOverstayRate = 20.0; // Penalty rate per extra hour
    
    // Check if duration is 2 hours (7200 seconds) or more
    if (difference.inSeconds >= 7200) { 
      // Calculate how many hours they overstayed. 
      // Using .ceil() ensures that even 1 minute over 2 hours charges for a full extra hour.
      int overstayHours = ((difference.inSeconds - 7200) / 3600).ceil();
      
      // If exactly 2 hours, overstay is 0. Anything over 2 hours becomes at least 1.
      int billableOverstay = overstayHours == 0 ? 1 : overstayHours;
      
      return baseRate + (billableOverstay * hourlyOverstayRate);
    }
    
    return baseRate;
  }

  // --- Persistence Methods ---
  Map<String, dynamic> toJson() => {
    'id': id,
    'plate': plate,
    'timeIn': timeIn.toIso8601String(),
    'timeOut': timeOut?.toIso8601String(),
    'zone': zone,
    'status': status.name,
  };

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
    id: json['id'],
    plate: json['plate'],
    timeIn: DateTime.parse(json['timeIn']),
    timeOut: json['timeOut'] != null ? DateTime.parse(json['timeOut']) : null,
    zone: json['zone'],
    status: TicketStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => TicketStatus.active,
    ),
  );
}