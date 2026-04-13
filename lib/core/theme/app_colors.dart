import 'package:flutter/material.dart';

class AppColors {
  // System Semantic Variables (Mapped to new design system where applicable)
  // To avoid breaking code drastically before we refactor every view, we map some old vars to new ones.
  static const backgroundDark = Color(0xFFF6FAFF); // Re-mapped to surface
  static const border = Color(0xFFEBF5FF); // Re-mapped to surfaceContainerLow or transparent
  static const textMain = Color(0xFF0E1D28); // on-surface
  static const muted = Color(0xFF586F80); // Adjusted to a blue-grey variant
  static const success = Color(0xFF00E676);
  static const danger = Color(0xFFFF3D00);
  
  // Aerostatic Utility Specific Tokens
  static const surface = Color(0xFFF6FAFF);
  static const surfaceContainerLow = Color(0xFFEBF5FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerHigh = Color(0xFFDAEAF9);
  
  static const primary = Color(0xFF0053CC);
  static const primaryContainer = Color(0xFF006AFF);
  static const primaryFixed = Color(0xFFEBF5FF); // Assuming similar to low
  static const onPrimaryFixed = Color(0xFF0053CC);
  
  static const onSurface = Color(0xFF0E1D28);
  
  static const secondary = Color(0xFF00D4E0);
  static const secondaryContainer = Color(0xFF4BF2FE);
  static const onSecondaryContainer = Color(0xFF006C72);
  
  static const outlineVariant = Color(0xFFC2C6D8);
  static const surfaceVariant = Color(0xFFF0F4F8); // Custom smooth surface variant
}