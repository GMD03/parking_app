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
}