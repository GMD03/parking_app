import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/ticket_model.dart';
import '../../ticket_entry/views/ticket_entry_view.dart';
import '../../ticket_entry/controllers/ticket_entry_controller.dart';

// Helper class for Zone UI mapping
class ZoneStats {
  final String name;
  final int capacity;
  final int occupied;
  ZoneStats(this.name, this.capacity, this.occupied);
  double get fillPercentage => capacity == 0 ? 0 : occupied / capacity;
}

class DashboardController extends GetxController {
  final currentTime = ''.obs;
  Timer? _timer;

  // Dynamic Telemetry Stats
  late int totalCapacity;
  final availableSlots = 0.obs;
  final occupiedSlots = 0.obs;
  final ticketsToday = 0.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Real data structure replacing hardcoded dummy zones
  final RxList<ZoneStats> zones = <ZoneStats>[].obs;

  final RxList<TicketModel> allTickets = <TicketModel>[
    TicketModel(id: '#78901', plate: 'OVR-9999', timeIn: '06:00:00', duration: '08:32:15', status: TicketStatus.overstay, zone: 'LEVEL_A'), // Added zone
  ].obs;

  List<TicketModel> get filteredTickets {
    if (searchQuery.value.isEmpty) return allTickets;
    return allTickets.where((t) => 
      t.plate.toLowerCase().contains(searchQuery.value.toLowerCase()) || 
      t.id.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _startClock();
    searchController.addListener(() => searchQuery.value = searchController.text);
    
    _loadPersistedSetupData();
    
    // Initialize global stats based on tickets (1 hardcoded overstay currently)
    occupiedSlots.value = allTickets.length;
    availableSlots.value = totalCapacity - occupiedSlots.value;
    ticketsToday.value = allTickets.length; 
  }

  void _loadPersistedSetupData() {
    final box = GetStorage();
    
    // 1. Get Global Capacity
    totalCapacity = box.read('totalFacilityCapacity') ?? 500;
    
    // 2. Hydrate the Zones List from local storage
    List<dynamic>? storedZones = box.read('configuredZones');
    
    if (storedZones != null && storedZones.isNotEmpty) {
      zones.value = storedZones.map((z) => ZoneStats(
        z['name'] as String,
        z['capacity'] as int,
        z['occupied'] as int,
      )).toList();
    } else {
      // Fallback fail-safe if data is corrupted
      zones.value = [ZoneStats('SYSTEM_ERR', totalCapacity, 0)];
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

    final newTicket = TicketModel(
      id: newId,
      plate: plate.toUpperCase(),
      timeIn: timeString,
      duration: '00:00:00', 
      status: TicketStatus.active,
      zone: zoneName, // <-- Save the zone to the ticket
    );

    allTickets.insert(0, newTicket); 
    
    ticketsToday.value++;
    occupiedSlots.value++;
    availableSlots.value--;
    
    // Dynamically update the specific Zone's occupied count!
    final zoneIndex = zones.indexWhere((z) => z.name == zoneName);
    if (zoneIndex != -1) {
      final z = zones[zoneIndex];
      // Create a new ZoneStats object with the updated occupied count to trigger the RxList update
      zones[zoneIndex] = ZoneStats(z.name, z.capacity, z.occupied + 1);
    }
  }

  void checkoutTicket(String ticketId) {
    allTickets.removeWhere((t) => t.id == ticketId);
    occupiedSlots.value--;
    availableSlots.value++;
  }

  void logout() {
    Get.offAllNamed('/login');
  }
  
  void syncNow() {}

  void openNewTicketPanel() {
    Get.generalDialog(
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: true,
      barrierLabel: 'TicketEntry',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => const TicketEntryView(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    ); 
  }
}