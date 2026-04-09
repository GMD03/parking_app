import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ticket_model.dart';

class DashboardController extends GetxController {
  // Live Clock
  final currentTime = ''.obs;
  Timer? _timer;

  // Telemetry Stats
  final availableSlots = 245.obs;
  final occupiedSlots = 55.obs;
  final ticketsToday = 300.obs;

  // Search functionality
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Master list of tickets (Mock data based on your UI design)
  final List<TicketModel> _allTickets = [
    TicketModel(id: '#78921', plate: 'ABC-1234', timeIn: '08:15:22', duration: '05:50:00', status: TicketStatus.active),
    TicketModel(id: '#78922', plate: 'XYZ-9876', timeIn: '09:30:10', duration: '04:35:12', status: TicketStatus.active),
    TicketModel(id: '#78923', plate: 'LMN-4567', timeIn: '10:05:45', duration: '03:59:37', status: TicketStatus.overstay),
    TicketModel(id: '#78924', plate: 'QRS-8822', timeIn: '11:20:00', duration: '02:45:22', status: TicketStatus.active),
    TicketModel(id: '#78925', plate: 'DEF-3344', timeIn: '12:10:15', duration: '01:55:07', status: TicketStatus.active),
    TicketModel(id: '#78926', plate: 'GHI-5566', timeIn: '13:00:00', duration: '01:05:22', status: TicketStatus.active),
    TicketModel(id: '#78927', plate: 'JKL-7788', timeIn: '13:30:45', duration: '00:34:37', status: TicketStatus.active),
    TicketModel(id: '#78928', plate: 'MNO-9900', timeIn: '13:45:10', duration: '00:20:12', status: TicketStatus.processing),
    TicketModel(id: '#78929', plate: 'PQR-1122', timeIn: '13:55:00', duration: '00:10:22', status: TicketStatus.active),
    TicketModel(id: '#78930', plate: 'STU-3344', timeIn: '14:02:15', duration: '00:03:07', status: TicketStatus.active),
  ];

  // Derived list that updates automatically when search query changes
  List<TicketModel> get filteredTickets {
    if (searchQuery.value.isEmpty) return _allTickets;
    return _allTickets.where((t) => 
      t.plate.toLowerCase().contains(searchQuery.value.toLowerCase()) || 
      t.id.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _startClock();
    
    // Listen to search input
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _startClock() {
    _updateTime(); // Initial call
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    final ms = (now.millisecond ~/ 10).toString().padLeft(2, '0');
    currentTime.value = '$h:$m:$s:$ms';
  }

  void logout() {
    Get.offAllNamed('/login');
  }

  void syncNow() {
    // Implement sync logic
  }

  void openNewTicketPanel() {
    // This will open the Ticket Entry Panel (Next Task)
    Get.snackbar('ACTION', 'Opening New Ticket Panel...', snackPosition: SnackPosition.BOTTOM);
  }
}