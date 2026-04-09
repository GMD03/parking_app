import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ticket_model.dart';
import '../../ticket_entry/views/ticket_entry_view.dart';
import '../../ticket_entry/controllers/ticket_entry_controller.dart';

// Helper class for tracking zone occupancies
class ZoneStats {
  final String name;
  final int capacity;
  final RxInt occupied;
  ZoneStats({required this.name, required this.capacity, int initialOccupied = 0}) : occupied = initialOccupied.obs;
}

class DashboardController extends GetxController {
  final currentTime = ''.obs;
  Timer? _timer;

  // Master Telemetry
  late int totalCapacity;
  final availableSlots = 0.obs;
  final occupiedSlots = 0.obs;
  final ticketsToday = 0.obs;

  // Zone Telemetry
  final RxList<ZoneStats> zones = <ZoneStats>[].obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  final RxList<TicketModel> allTickets = <TicketModel>[
    TicketModel(id: '#78901', plate: 'OVR-9999', timeIn: '06:00:00', duration: '08:32:15', zone: 'LEVEL_A', status: TicketStatus.overstay),
  ].obs;

  List<TicketModel> get filteredTickets {
    if (searchQuery.value.isEmpty) return allTickets;
    return allTickets.where((t) => t.plate.toLowerCase().contains(searchQuery.value.toLowerCase()) || t.id.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _startClock();
    searchController.addListener(() => searchQuery.value = searchController.text);
    
    // 1. Receive Data from Zone Setup
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      totalCapacity = args['totalCapacity'] ?? 500;
      final zoneList = args['zones'] as List<dynamic>? ?? [];
      for (var z in zoneList) {
        zones.add(ZoneStats(name: z['name'], capacity: z['capacity']));
      }
    } else {
      // Fallback if debugging directly to Dashboard
      totalCapacity = 500;
      zones.add(ZoneStats(name: 'LEVEL_A', capacity: 200));
      zones.add(ZoneStats(name: 'LEVEL_B', capacity: 150));
    }

    // 2. Initialize Telemetry Math
    occupiedSlots.value = allTickets.length;
    availableSlots.value = totalCapacity - occupiedSlots.value;
    ticketsToday.value = allTickets.length;

    // Attribute existing overstay ticket to its zone
    for (var t in allTickets) {
      final z = zones.firstWhereOrNull((z) => z.name == t.zone);
      if (z != null) z.occupied.value++;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    final ms = (now.millisecond ~/ 10).toString().padLeft(2, '0');
    currentTime.value = '$h:$m:$s:$ms';
  }

  void addTicket(String plate, String vehicleClass, String zoneName) {
    final now = DateTime.now();
    final timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    final newId = '#${78900 + ticketsToday.value + 1}';

    allTickets.insert(0, TicketModel(
      id: newId, plate: plate.toUpperCase(), timeIn: timeString, duration: '00:00:00', zone: zoneName, status: TicketStatus.active,
    )); 
    
    // Update Master Telemetry
    ticketsToday.value++;
    occupiedSlots.value++;
    availableSlots.value--;

    // Update Zone Telemetry
    final z = zones.firstWhereOrNull((z) => z.name == zoneName);
    if (z != null) z.occupied.value++;
  }

  void checkoutTicket(String ticketId) {
    final ticket = allTickets.firstWhereOrNull((t) => t.id == ticketId);
    if (ticket != null) {
      // Free up specific zone
      final z = zones.firstWhereOrNull((z) => z.name == ticket.zone);
      if (z != null) z.occupied.value--;

      // Update Master Telemetry
      allTickets.remove(ticket);
      occupiedSlots.value--;
      availableSlots.value++;
    }
  }

  void logout() => Get.offAllNamed('/login');
  void syncNow() {}

  void openNewTicketPanel() {
    Get.lazyPut(() => TicketEntryController());
    Get.generalDialog(
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: true,
      barrierLabel: 'TicketEntry',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => const TicketEntryView(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)), child: child);
      },
    ).then((_) => Get.delete<TicketEntryController>());
  }
}