// lib/modules/dashboard/controllers/dashboard_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ticket_model.dart';
import '../../ticket_entry/views/ticket_entry_view.dart';
import '../../login/controllers/login_controller.dart';
import '../../device_registration/controllers/device_registration_controller.dart';
import '../../config_setup/controllers/config_controller.dart';
import '../../zone_setup/controllers/zone_setup_controller.dart';

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
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  final operatorId = 'GUEST'.obs;
  final terminalId = 'UNKNOWN'.obs;
  final syncMode = 'LOCAL'.obs;
  
  late int totalCapacity;
  final availableSlots = 0.obs;
  final occupiedSlots = 0.obs;
  final ticketsToday = 0.obs;

  final RxList<ZoneStats> zones = <ZoneStats>[].obs;

  //Dummy data for testing. In a real app, this would come from a database or API.
  final RxList<TicketModel> allTickets = <TicketModel>[
    TicketModel(
      id: '#78901', 
      plate: 'OVR9119', 
      timeIn: DateTime.now().subtract(const Duration(hours: 3)), 
      zone: 'LEVEL_A', 
      vehicleClass: 'CAR', 
      status: TicketStatus.overstay
    ),
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
    _initializeSystemData();
    
    occupiedSlots.value = allTickets.length;
    availableSlots.value = totalCapacity - occupiedSlots.value;
    ticketsToday.value = allTickets.length; 
  }

  void _initializeSystemData() {
    final user = LoginController.getCurrentUser();
    operatorId.value = user?.operatorId ?? 'GUEST';
    
    final device = DeviceRegistrationController.getRegisteredDevice();
    terminalId.value = device?.terminalId ?? 'UNKNOWN';

    final config = ConfigController.getSystemConfig();
    syncMode.value = config?.syncMode.name.toUpperCase() ?? 'LOCAL';

    totalCapacity = ZoneSetupController.getTotalCapacity();
    final storedZones = ZoneSetupController.getConfiguredZones();
    zones.value = storedZones.map((z) => ZoneStats(
      z['name'] as String,
      z['capacity'] as int,
      z['occupied'] as int,
    )).toList();
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

  int _lastSecond = -1;

  void _updateTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    final ms = (now.millisecond ~/ 10).toString().padLeft(2, '0');
    currentTime.value = '$h:$m:$s:$ms';

    if (now.second != _lastSecond) {
      _lastSecond = now.second;
      
      // NEW LOGIC: Scan for tickets that have crossed the 2-hour mark
      for (var ticket in allTickets) {
        if (ticket.status == TicketStatus.active) {
          final difference = now.difference(ticket.timeIn);
          // 7200 seconds == exactly 2 hours
          if (difference.inSeconds >= 7200) {
            ticket.status = TicketStatus.overstay;
          }
        }
      }

      // This tells GetX to recalculate durations, statuses, and due amounts!
      allTickets.refresh(); 
    }
  }

  void addTicket(String plate, String vehicleClass, String zoneName) {
    final newId = '#${78900 + ticketsToday.value + 1}';

    final newTicket = TicketModel(
      id: newId,
      plate: plate.toUpperCase(),
      timeIn: DateTime.now(),
      status: TicketStatus.active,
      zone: zoneName, 
      vehicleClass: vehicleClass, 
    );

    allTickets.insert(0, newTicket); 
    
    ticketsToday.value++;
    occupiedSlots.value++;
    availableSlots.value--;
    
    final zoneIndex = zones.indexWhere((z) => z.name == zoneName);
    if (zoneIndex != -1) {
      final z = zones[zoneIndex];
      zones[zoneIndex] = ZoneStats(z.name, z.capacity, z.occupied + 1);
    }
  }

  void initiateCheckout(String ticketId) {
    final ticketIndex = allTickets.indexWhere((t) => t.id == ticketId);
    if (ticketIndex == -1) return;

    final ticket = allTickets[ticketIndex];
    ticket.status = TicketStatus.processing;
    ticket.timeOut = DateTime.now(); // Freezes the duration & totalDue calculation
    
    allTickets.refresh();
  }

  void finalizeCheckout(String ticketId) {
    final ticketIndex = allTickets.indexWhere((t) => t.id == ticketId);
    if (ticketIndex == -1) return;

    final ticket = allTickets[ticketIndex];
    
    final zoneIndex = zones.indexWhere((z) => z.name == ticket.zone);
    if (zoneIndex != -1) {
      final z = zones[zoneIndex];
      final newOccupied = (z.occupied - 1) < 0 ? 0 : (z.occupied - 1);
      zones[zoneIndex] = ZoneStats(z.name, z.capacity, newOccupied);
    }

    allTickets.removeAt(ticketIndex);
    occupiedSlots.value--;
    availableSlots.value++;
  }

  void logout() => Get.offAllNamed('/login');
  
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