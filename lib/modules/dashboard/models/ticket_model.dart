enum TicketStatus { active, overstay, processing }

class TicketModel {
  final String id;
  final String plate;
  final String timeIn;
  final String duration;
  final String zone;
  final TicketStatus status;

  TicketModel({
    required this.id,
    required this.plate,
    required this.timeIn,
    required this.duration,
    required this.zone,
    required this.status,
  });
}