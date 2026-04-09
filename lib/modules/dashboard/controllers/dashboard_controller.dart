import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ticket_model.dart';
import '../../ticket_entry/views/ticket_entry_view.dart';
import '../../ticket_entry/controllers/ticket_entry_controller.dart';

class ZoneStats {
  final String name;
  final int capacity;
  final RxInt occupied;
  ZoneStats({required this.name, required this.capacity, int initialOccupied = 0}) : occupied = initialOccupied.obs;
}

class DashboardController extends GetxController {
  final currentTime = ''.obs;
  Timer? _timer;

  late int totalCapacity;
  final availableSlots = 0.obs;
  final occupiedSlots = 0.obs;
  final ticketsToday = 0.obs;

  final RxList<ZoneStats> zones = <ZoneStats>[].obs;
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Dynamic Ticket List
  final RxList<TicketModel> allTickets = <TicketModel>[].obs;

  List<TicketModel> get filteredTickets {
    if (searchQuery.value.isEmpty) return allTickets;
    return allTickets.where((t) => t.plate.toLowerCase().contains(searchQuery.value.toLowerCase()) || t.id.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _startClock();
    searchController.addListener(() => searchQuery.value = searchController.text);
    
    // Receive setup data
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      totalCapacity = args['totalCapacity'] ?? 500;
      final zoneList = args['zones'] as List<dynamic>? ?? [];
      for (var z in zoneList) {
        zones.add(ZoneStats(name: z['name'], capacity: z['capacity']));
      }
    } else {
      // Fallback if testing directly
      totalCapacity = 500;
      zones.add(ZoneStats(name: 'LEVEL_A', capacity: 200));
    }

    availableSlots.value = totalCapacity;
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
    currentTime.value = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  // --- ADD & REMOVE TICKETS ---
  void addTicket(String plate, String vehicleClass, String zoneName) {
    final newId = '#${78900 + ticketsToday.value + 1}';
    
    // 1. Add to table
    allTickets.insert(0, TicketModel(
      id: newId, plate: plate.toUpperCase(), timeIn: currentTime.value, duration: '00:00:00', zone: zoneName, status: TicketStatus.active,
    )); 
    
    // 2. Update global stats
    ticketsToday.value++;
    occupiedSlots.value++;
    availableSlots.value--;

    // 3. Update specific zone stats
    final z = zones.firstWhereOrNull((z) => z.name == zoneName);
    if (z != null) z.occupied.value++;
  }

  void checkoutTicket(String ticketId) {
    final ticket = allTickets.firstWhereOrNull((t) => t.id == ticketId);
    if (ticket != null) {
      final z = zones.firstWhereOrNull((z) => z.name == ticket.zone);
      if (z != null) z.occupied.value--;

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
      barrierDismissible: true, barrierLabel: 'TicketEntry',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => const TicketEntryView(),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)), child: child);
      },
    ).then((_) => Get.delete<TicketEntryController>());
  }
}