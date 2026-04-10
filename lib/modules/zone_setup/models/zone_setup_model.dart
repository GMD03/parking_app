// lib/modules/zone_setup/models/zone_setup_model.dart

import 'package:flutter/material.dart';

class ZoneRowData {
  final TextEditingController nameController;
  final TextEditingController spotsController;

  ZoneRowData({required String name, required String spots})
      : nameController = TextEditingController(text: name),
        spotsController = TextEditingController(text: spots);

  void dispose() {
    nameController.dispose();
    spotsController.dispose();
  }

  // --- Serialization for Persistence ---
  Map<String, dynamic> toJson() => {
        'name': nameController.text.trim(),
        'capacity': int.tryParse(spotsController.text) ?? 0,
        'occupied': 0, // Initial state is always 0
      };

  // --- Deserialization ---
  factory ZoneRowData.fromJson(Map<String, dynamic> json) => ZoneRowData(
        name: json['name'] ?? 'UNNAMED_ZONE',
        spots: (json['capacity'] ?? 0).toString(),
      );
}