import 'package:flutter/material.dart';
import '../models/pricing_config.dart';

class BillingEngine {
  /// Calculate the total due based on the provided configuration matrix.
  static double calculateDue(DateTime timeIn, DateTime timeOut, PricingConfig config) {
    double totalDue = 0.0;
    
    // 2. Base Rate applies immediately once free period is surpassed.
    totalDue += config.baseRate;
    
    DateTime currentTimePointer = timeIn.add(Duration(hours: config.baseHours));
    
    bool hasOvernight = (config.scheduleType == ScheduleType.regularWithOvernight || config.scheduleType == ScheduleType.twentyFourHoursWithOvernight);
    bool isRegular = (config.scheduleType == ScheduleType.regular || config.scheduleType == ScheduleType.regularWithOvernight);

    // If they checked out before base hours exhausted
    if (timeOut.isBefore(currentTimePointer) || timeOut.isAtSameMomentAs(currentTimePointer)) {
        if (hasOvernight && _intersectsOvernight(timeIn, timeOut, config)) {
            totalDue += config.overnightRate;
        }
        return totalDue;
    }

    // Base Period Overnight Check
    if (hasOvernight && _intersectsOvernight(timeIn, currentTimePointer, config)) {
        totalDue += config.overnightRate;
    }

    int remainingMinutes = timeOut.difference(currentTimePointer).inMinutes;

    switch (config.scheduleType) {
      case ScheduleType.twentyFourHours:
        // Trigger base rate (done) -> Trigger Grace Period -> Succeeding Rate
        if (remainingMinutes <= config.gracePeriodMinutes) {
          return totalDue;
        }
        int succeedingBlocks = (remainingMinutes / (config.succeedingPeriod * 60.0)).ceil();
        totalDue += (succeedingBlocks * config.succeedingRate);
        break;

      case ScheduleType.twentyFourHoursWithOvernight:
        totalDue = _loopSucceedingWithOvernight(currentTimePointer, timeOut, config, totalDue, true, false, true);
        break;

      case ScheduleType.regular:
        totalDue = _loopSucceedingWithOvernight(currentTimePointer, timeOut, config, totalDue, false, true, false);
        break;

      case ScheduleType.regularWithOvernight:
        totalDue = _loopSucceedingWithOvernight(currentTimePointer, timeOut, config, totalDue, true, true, false);
        break;
    }

    return totalDue;
  }

  /// Iteratively sweeps forwards through unbilled time
  static double _loopSucceedingWithOvernight(
    DateTime pointer, 
    DateTime timeOut, 
    PricingConfig config, 
    double currentTotal, 
    bool hasOvernight,
    [bool isRegularSchedule = false, bool isOvernightAdditional = false]
  ) {
    double total = currentTotal;
    // Assume if we entered overnight in base period, we track it nicely by checking thresholds.
    // To prevent double charging the first night if base period crossed it: 
    DateTime lastOvernightDay = pointer.subtract(const Duration(days: 99)); // Default past
    bool isOvernightActive = false;

    // Check if pointer is currently in overnight timeframe
    if (hasOvernight && _isTimeInOvernightWindow(pointer, config)) {
       isOvernightActive = true;
       // Align lastOvernightDay to start of this evening
       lastOvernightDay = DateTime(pointer.year, pointer.month, pointer.day);
       if (pointer.hour < 12) {
         lastOvernightDay = lastOvernightDay.subtract(const Duration(days: 1)); // Belongs to previous day's evening
       }
    }

    DateTime lastBaseRateDay = pointer.subtract(Duration(hours: config.baseHours)); // The day they came in

    while (pointer.isBefore(timeOut)) {
      // 1. Reset overnight active status if we hit open time on a new day
      if (isOvernightActive) {
          DateTime openThreshold = DateTime(pointer.year, pointer.month, pointer.day, config.openTime.hour, config.openTime.minute);
          // If we are evaluating a block that crosses 6am, or pointer is deeply past it
          if (pointer.isAfter(openThreshold) || pointer.isAtSameMomentAs(openThreshold)) {
             // Only reset if this 6am is strictly after the last overnight trigger day (i.e. next morning)
             if (openThreshold.isAfter(lastOvernightDay.add(const Duration(hours: 12)))) {
                 isOvernightActive = false;
             }
          }
      }

      // 2. Regular Schedule Logic: Next Day Reset
      if (isRegularSchedule) {
        if (pointer.day != lastBaseRateDay.day && _isAfterOrEqualTimeOfDay(pointer, config.openTime)) {
          total += config.baseRate;
          lastBaseRateDay = pointer;
          pointer = pointer.add(Duration(hours: config.baseHours)); // Skip ahead
          continue;
        }
      }

      DateTime nextBlock = pointer.add(Duration(hours: config.succeedingPeriod));
      DateTime actualEnd = timeOut.isBefore(nextBlock) ? timeOut : nextBlock;
      
      // 3. Determine if we should trigger Overnight
      if (hasOvernight && !isOvernightActive) {
        DateTime threshold = DateTime(pointer.year, pointer.month, pointer.day, config.overnightTime.hour, config.overnightTime.minute).add(Duration(minutes: config.gracePeriodMinutes));
        if (actualEnd.isAfter(threshold) || actualEnd.isAtSameMomentAs(threshold)) {
          total += config.overnightRate;
          isOvernightActive = true;
          lastOvernightDay = DateTime(threshold.year, threshold.month, threshold.day);
        }
      } 
      
      // 4. Apply Succeeding Block Logic
      if (!isOvernightActive || isOvernightAdditional) {
        if (nextBlock.isAfter(timeOut)) {
          int leftoverMinutes = timeOut.difference(pointer).inMinutes;
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

  static bool _intersectsOvernight(DateTime start, DateTime end, PricingConfig config) {
    DateTime c = DateTime(start.year, start.month, start.day);
    DateTime e = DateTime(end.year, end.month, end.day);
    while (!c.isAfter(e)) {
      DateTime threshold = DateTime(c.year, c.month, c.day, config.overnightTime.hour, config.overnightTime.minute).add(Duration(minutes: config.gracePeriodMinutes));
      DateTime openNext = DateTime(c.year, c.month, c.day + 1, config.openTime.hour, config.openTime.minute);
      
      // An overnight window for day C is [threshold, openNext]
      // Check if [start, end] overlaps with [threshold, openNext]
      bool startBeforeWindowEnds = start.isBefore(openNext);
      bool endAfterWindowStarts = end.isAfter(threshold) || end.isAtSameMomentAs(threshold);
      if (startBeforeWindowEnds && endAfterWindowStarts) return true;
      
      c = c.add(const Duration(days: 1));
    }
    
    // Check previous day's evening if start is early morning
    DateTime prevC = DateTime(start.year, start.month, start.day - 1);
    DateTime prevThreshold = DateTime(prevC.year, prevC.month, prevC.day, config.overnightTime.hour, config.overnightTime.minute).add(Duration(minutes: config.gracePeriodMinutes));
    DateTime prevOpenNext = DateTime(prevC.year, prevC.month, prevC.day + 1, config.openTime.hour, config.openTime.minute);
    
    if (start.isBefore(prevOpenNext) && (end.isAfter(prevThreshold) || end.isAtSameMomentAs(prevThreshold))) return true;

    return false;
  }

  static bool _isTimeInOvernightWindow(DateTime t, PricingConfig config) {
     DateTime currentEvening = DateTime(t.year, t.month, t.day, config.overnightTime.hour, config.overnightTime.minute).add(Duration(minutes: config.gracePeriodMinutes));
     DateTime currentMorning = DateTime(t.year, t.month, t.day, config.openTime.hour, config.openTime.minute);
     
     if (t.isAfter(currentEvening) || t.isAtSameMomentAs(currentEvening)) return true;
     if (t.isBefore(currentMorning)) return true; // Belongs to previous day's evening
     
     return false;
  }

  static bool _isAfterOrEqualTimeOfDay(DateTime pointer, TimeOfDay time) {
    if (pointer.hour > time.hour) return true;
    if (pointer.hour == time.hour && pointer.minute >= time.minute) return true;
    return false;
  }
}
