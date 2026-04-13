import 'package:flutter/material.dart';

enum ScheduleType {
  twentyFourHours,
  twentyFourHoursWithOvernight,
  regular,
  regularWithOvernight,
}

class PricingConfig {
  ScheduleType scheduleType;
  
  // Triggers
  int freePeriodMinutes; 
  int gracePeriodMinutes; 
  
  // Rates
  double baseRate;
  int baseHours;
  double succeedingRate;
  double overnightRate;
  
  // Times
  TimeOfDay openTime;
  TimeOfDay closeTime;
  TimeOfDay overnightTime;

  PricingConfig({
    required this.scheduleType,
    required this.freePeriodMinutes,
    required this.gracePeriodMinutes,
    required this.baseRate,
    required this.baseHours,
    required this.succeedingRate,
    required this.overnightRate,
    required this.openTime,
    required this.closeTime,
    required this.overnightTime,
  });
  
  // 1. Standard 24 Hours
  factory PricingConfig.default24Hour() {
    return PricingConfig(
      scheduleType: ScheduleType.twentyFourHours,
      freePeriodMinutes: 15,
      gracePeriodMinutes: 5,
      baseRate: 20.0,
      baseHours: 3,
      succeedingRate: 10.0,
      overnightRate: 150.0,
      openTime: const TimeOfDay(hour: 6, minute: 0),
      closeTime: const TimeOfDay(hour: 22, minute: 0),
      overnightTime: const TimeOfDay(hour: 22, minute: 0),
    );
  }

  // 2. 24 Hours with Overnight Trigger
  factory PricingConfig.twentyFourHourOvernight() {
    return PricingConfig(
      scheduleType: ScheduleType.twentyFourHoursWithOvernight,
      freePeriodMinutes: 15,
      gracePeriodMinutes: 5,
      baseRate: 20.0,
      baseHours: 3,
      succeedingRate: 10.0,
      overnightRate: 150.0,
      openTime: const TimeOfDay(hour: 6, minute: 0),
      closeTime: const TimeOfDay(hour: 22, minute: 0),
      overnightTime: const TimeOfDay(hour: 22, minute: 0),
    );
  }

  // 3. Regular Schedule
  factory PricingConfig.regular() {
    return PricingConfig(
      scheduleType: ScheduleType.regular,
      freePeriodMinutes: 15,
      gracePeriodMinutes: 5,
      baseRate: 20.0,
      baseHours: 2,
      succeedingRate: 20.0,
      overnightRate: 150.0,
      openTime: const TimeOfDay(hour: 6, minute: 0),
      closeTime: const TimeOfDay(hour: 22, minute: 0),
      overnightTime: const TimeOfDay(hour: 22, minute: 0),
    );
  }

  // 4. Regular Schedule with Overnight
  factory PricingConfig.regularWithOvernight() {
    return PricingConfig(
      scheduleType: ScheduleType.regularWithOvernight,
      freePeriodMinutes: 15,
      gracePeriodMinutes: 5,
      baseRate: 20.0,
      baseHours: 2,
      succeedingRate: 20.0,
      overnightRate: 200.0,
      openTime: const TimeOfDay(hour: 6, minute: 0),
      closeTime: const TimeOfDay(hour: 22, minute: 0),
      overnightTime: const TimeOfDay(hour: 22, minute: 0),
    );
  }
}
