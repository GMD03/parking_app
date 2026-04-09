import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Added GetStorage import
import '../models/ticket_model.dart';
import '../../ticket_entry/views/ticket_entry_view.dart';
import '../../ticket_entry/controllers/ticket_entry_controller.dart';

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

  // CHANGED: Converted to RxList. Retained exactly ONE overstay ticket.
  final RxList<TicketModel> allTickets = <TicketModel>[
    TicketModel(id: '#78901', plate: 'OVR-9999', timeIn: '06:00:00', duration: '08:32:15', status: TicketStatus.overstay),
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
    
    // THE FIX: Retrieve capacity from GetStorage instead of Get.arguments
    final box = GetStorage();
    totalCapacity = box.read('totalFacilityCapacity') ?? 500;
    
    // Initialize stats based on the 1 overstay ticket
    occupiedSlots.value = allTickets.length;
    availableSlots.value = totalCapacity - occupiedSlots.value;
    ticketsToday.value = allTickets.length; 
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

  // --- DATA MODIFICATION METHODS ---

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

    // Insert at top of UI list
    allTickets.insert(0, newTicket); 
    
    // Update Telemetry
    ticketsToday.value++;
    occupiedSlots.value++;
    availableSlots.value--;
  }

  void checkoutTicket(String ticketId) {
    allTickets.removeWhere((t) => t.id == ticketId);
    
    // Free up the slot, but do NOT decrement ticketsToday
    occupiedSlots.value--;
    availableSlots.value++;
  }

  void logout() {
    // Optional: You might want to clear Get.arguments here depending on your auth flow
    Get.offAllNamed('/login');
  }
  
  void syncNow() {}

void openNewTicketPanel() {
    // THE FIX: Use Get.put() instead of Get.lazyPut() to inject it into memory instantly
    Get.put(TicketEntryController());
    
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
    ).then((_) => Get.delete<TicketEntryController>()); // Cleans up when dialog closes
  }
}