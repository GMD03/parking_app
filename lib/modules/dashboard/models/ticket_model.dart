// lib/modules/dashboard/models/ticket_model.dart

enum TicketStatus { active, overstay, processing }

class TicketModel {
  final String id;
  final String plate;
  final DateTime timeIn;    // CHANGED: From String to DateTime
  DateTime? timeOut;        // NEW: To freeze the duration calculation on checkout
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
    // If the ticket is checked out, calculate based on timeOut. Otherwise, use current time.
    final endTime = timeOut ?? DateTime.now();
    final difference = endTime.difference(timeIn);
    
    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    
    return "$hours:$minutes:$seconds";
  }

  // --- Persistence Methods (For future local storage support) ---
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