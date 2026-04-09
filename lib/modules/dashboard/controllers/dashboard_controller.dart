import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ticket_model.dart';
import '../../ticket_entry/views/ticket_entry_view.dart';
import '../../ticket_entry/controllers/ticket_entry_controller.dart';

class DashboardController extends GetxController {
  // Live Clock
  final currentTime = ''.obs;
  Timer? _timer;

  // Telemetry Stats
  final totalCapacity = 500;
  final availableSlots = 245.obs;
  final occupiedSlots = 55.obs;
  final ticketsToday = 300.obs;

  // Search functionality
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // CHANGED: This must be an RxList so the UI updates when tickets are added/removed
  final RxList<TicketModel> allTickets = <TicketModel>[
    TicketModel(id: '#78921', plate: 'ABC-1234', timeIn: '08:15:22', duration: '05:50:00', status: TicketStatus.active),
    TicketModel(id: '#78922', plate: 'XYZ-9876', timeIn: '09:30:10', duration: '04:35:12', status: TicketStatus.active),
    TicketModel(id: '#78923', plate: 'LMN-4567', timeIn: '10:05:45', duration: '03:59:37', status: TicketStatus.overstay),
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
    
    // Initialize stats based on current list
    occupiedSlots.value = allTickets.length;
    availableSlots.value = totalCapacity - occupiedSlots.value;
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

  // --- ADDED: Functional Logic to modify the list ---
  void addTicket(String plate, String vehicleClass) {
    final now = DateTime.now();
    final timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    
    final newId = '#${78900 + ticketsToday.value + 1}';

    final newTicket = TicketModel(
      id: newId,
      plate: plate.toUpperCase(),
      timeIn: timeString,
      duration: '00:00:00', 
      status: TicketStatus.active,
    );

    allTickets.insert(0, newTicket); // Adds to top of list
    
    ticketsToday.value++;
    occupiedSlots.value++;
    availableSlots.value--;
  }

  void checkoutTicket(String ticketId) {
    allTickets.removeWhere((t) => t.id == ticketId);
    occupiedSlots.value--;
    availableSlots.value++;
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
      pageBuilder: (context, animation, secondaryAnimation) {
        return const TicketEntryView();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    ).then((_) {
      Get.delete<TicketEntryController>();
    });
  }
}