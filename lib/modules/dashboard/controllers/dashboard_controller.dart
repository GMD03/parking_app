// lib/modules/dashboard/controllers/dashboard_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ticket_model.dart';
import '../../ticket_entry/views/ticket_entry_view.dart';
import '../../device_registration/controllers/device_registration_controller.dart';
import '../../config_setup/controllers/config_controller.dart';
import '../../zone_setup/controllers/zone_setup_controller.dart';
import '../../../core/services/database_service.dart';

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

  // Dynamic SQLite DB binding
  final RxList<TicketModel> allTickets = <TicketModel>[].obs;

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
    _loadDbTickets();
  }

  Future<void> _loadDbTickets() async {
    final List<Map<String, dynamic>> maps = await DatabaseService.instance.query('tickets');
    final dbTickets = maps.map((map) => TicketModel.fromJson(map)).toList();
    
    // Sort by most recent
    dbTickets.sort((a, b) => b.timeIn.compareTo(a.timeIn));
    
    allTickets.assignAll(dbTickets);
    _recalculateStats();
  }

  void _recalculateStats() {
    occupiedSlots.value = allTickets.length;
    availableSlots.value = totalCapacity - occupiedSlots.value;
    ticketsToday.value = allTickets.where((t) => t.timeIn.day == DateTime.now().day).length;

    for (int i=0; i<zones.length; i++) {
       final z = zones[i];
       final count = allTickets.where((t) => t.zone == z.name).length;
       zones[i] = ZoneStats(z.name, z.capacity, count);
    }
  }

  void _initializeSystemData() {
    final user = DatabaseService.getState('currentUser');
    operatorId.value = user != null ? user['operatorId'] ?? 'GUEST' : 'GUEST';
    
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
      bool changed = false;
      for (var ticket in allTickets) {
        if (ticket.status == TicketStatus.active) {
          final difference = now.difference(ticket.timeIn);
          if (difference.inSeconds >= 7200) {
            ticket.status = TicketStatus.overstay;
            changed = true;
            DatabaseService.instance.update('tickets', ticket.toJson(), where: 'id = ?', whereArgs: [ticket.id]);
          }
        }
      }
      if (changed) allTickets.refresh(); 
    }
  }

  Future<void> addTicket(String plate, String vehicleClass, String zoneName) async {
    final newId = '#${78900 + allTickets.length + 1}';

    final newTicket = TicketModel(
      id: newId,
      plate: plate.toUpperCase(),
      timeIn: DateTime.now(),
      status: TicketStatus.active,
      zone: zoneName, 
      vehicleClass: vehicleClass, 
    );

    await DatabaseService.instance.insert('tickets', newTicket.toJson());

    allTickets.insert(0, newTicket); 
    _recalculateStats();
  }

  Future<void> initiateCheckout(String ticketId) async {
    final ticketIndex = allTickets.indexWhere((t) => t.id == ticketId);
    if (ticketIndex == -1) return;

    final ticket = allTickets[ticketIndex];
    ticket.status = TicketStatus.processing;
    ticket.timeOut = DateTime.now(); 
    
    await DatabaseService.instance.update('tickets', ticket.toJson(), where: 'id = ?', whereArgs: [ticket.id]);

    allTickets.refresh();
  }

  Future<void> finalizeCheckout(String ticketId) async {
    final ticketIndex = allTickets.indexWhere((t) => t.id == ticketId);
    if (ticketIndex == -1) return;

    await DatabaseService.instance.delete('tickets', where: 'id = ?', whereArgs: [ticketId]);

    allTickets.removeAt(ticketIndex);
    _recalculateStats();
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