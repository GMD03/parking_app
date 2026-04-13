import 'package:flutter/material.dart';
import '../models/pricing_config.dart';

class BillingEngine {
  /// Calculate the total due based on the provided configuration matrix.
  static double calculateDue(DateTime timeIn, DateTime timeOut, PricingConfig config) {
    Duration totalDuration = timeOut.difference(timeIn);
    
    // 1. Trigger Free Period
    // If the vehicle exits before the free period expires, zero charge.
    if (totalDuration.inMinutes <= config.freePeriodMinutes) {
      return 0.0;
    }
    
    double totalDue = 0.0;
    
    // 2. Base Rate applies immediately once free period is surpassed.
    totalDue += config.baseRate;
    
    DateTime currentTimePointer = timeIn.add(Duration(hours: config.baseHours));
    
    // If they checked out before base hours exhausted
    if (timeOut.isBefore(currentTimePointer) || timeOut.isAtSameMomentAs(currentTimePointer)) {
        return totalDue;
    }
    
    // Process remaining time logic based on schedule
    int remainingMinutes = timeOut.difference(currentTimePointer).inMinutes;

    switch (config.scheduleType) {
      case ScheduleType.twentyFourHours:
        // Trigger base rate (done) -> Trigger Grace Period -> Succeeding Rate
        if (remainingMinutes <= config.gracePeriodMinutes) {
          return totalDue;
        }
        int succeedingHours = (remainingMinutes / 60.0).ceil();
        totalDue += (succeedingHours * config.succeedingRate);
        break;

      case ScheduleType.twentyFourHoursWithOvernight:
        totalDue = _loopSucceedingWithOvernight(currentTimePointer, timeOut, config, totalDue, false);
        break;

      case ScheduleType.regular:
        totalDue = _loopSucceedingWithOvernight(currentTimePointer, timeOut, config, totalDue, false, true);
        break;

      case ScheduleType.regularWithOvernight:
        totalDue = _loopSucceedingWithOvernight(currentTimePointer, timeOut, config, totalDue, true, true);
        break;
    }

    return totalDue;
  }

  /// Iteratively sweeps forwards through unbilled time hour by hour, 
  /// applying regular and overnight logic dynamically.
  static double _loopSucceedingWithOvernight(
    DateTime pointer, 
    DateTime timeOut, 
    PricingConfig config, 
    double currentTotal, 
    bool hasOvernight,
    [bool isRegularSchedule = false]
  ) {
    double total = currentTotal;
    bool isOvernightActive = false;
    DateTime lastBaseRateDay = pointer.subtract(Duration(hours: config.baseHours)); // The day they came in

    while (pointer.isBefore(timeOut)) {
      // Regular Schedule Logic: Next Day Reset
      if (isRegularSchedule) {
        // If we crossed into a new day and reached opening time
        if (pointer.day != lastBaseRateDay.day && _isAfterOrEqualTimeOfDay(pointer, config.openTime)) {
          total += config.baseRate;
          lastBaseRateDay = pointer;
          pointer = pointer.add(Duration(hours: config.baseHours)); // Skip ahead by base hours
          isOvernightActive = false;
          continue;
        }
      }

      DateTime nextBlock = pointer.add(const Duration(hours: 1));
      
      // Determine if we should trigger Overnight
      if (hasOvernight && !isOvernightActive && _isAfterOrEqualTimeOfDay(pointer, config.overnightTime)) {
        total += config.overnightRate;
        isOvernightActive = true;
      } 
      else if (!isOvernightActive) {
        // Evaluate succeeding hours safely respecting the grace period for the final block
        if (nextBlock.isAfter(timeOut)) {
          int leftoverMinutes = timeOut.difference(pointer).inMinutes;
          // Apply grace period check ONLY on the very last partial fraction
          if (leftoverMinutes > config.gracePeriodMinutes) {
            total += config.succeedingRate;
          }
        } else {
          total += config.succeedingRate;
        }
      }

      pointer = nextBlock;
    }
    return total;
  }

  static bool _isAfterOrEqualTimeOfDay(DateTime pointer, TimeOfDay time) {
    if (pointer.hour > time.hour) return true;
    if (pointer.hour == time.hour && pointer.minute >= time.minute) return true;
    return false;
  }
}
