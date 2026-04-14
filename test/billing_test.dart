import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/core/models/pricing_config.dart';
import 'package:parking_app/core/utils/billing_engine.dart';
import 'package:flutter/material.dart';

void main() {
  test('Test 24 Hours Rate', () {
    var config = PricingConfig.default24Hour();
    config.baseRate = 30;
    config.baseHours = 2;
    config.succeedingRate = 40;
    config.succeedingPeriod = 2;

    DateTime timeIn = DateTime(2023, 1, 1, 10, 0); 
    DateTime timeOut = DateTime(2023, 1, 1, 13, 30); 
    
    double due = BillingEngine.calculateDue(timeIn, timeOut, config);
    expect(due, 70.0);
  });

  test('Test Regular Rate with Overnight Trigger', () {
    var config = PricingConfig.regularWithOvernight();
    config.baseRate = 50;
    config.baseHours = 3;
    config.succeedingRate = 10;
    config.succeedingPeriod = 1;
    config.overnightRate = 150;
    config.gracePeriodMinutes = 15;

    DateTime timeIn = DateTime(2023, 1, 1, 16, 0); 
    DateTime timeOut = DateTime(2023, 1, 1, 18, 16); // 18:16 triggers overnight

    double due = BillingEngine.calculateDue(timeIn, timeOut, config);
    expect(due, 200.0);
  });

  test('Test 24H with Overnight Additional', () {
    var config = PricingConfig.twentyFourHourOvernight();
    config.baseRate = 50;
    config.baseHours = 3;
    config.succeedingRate = 10;
    config.succeedingPeriod = 1;
    config.overnightRate = 200;
    config.gracePeriodMinutes = 15;
    
    DateTime timeIn = DateTime(2023, 1, 1, 10, 0); 
    DateTime timeOut = DateTime(2023, 1, 1, 19, 0); // 10AM to 7PM -> 9 hours total
    // base (3hr) = 50. 
    // remaining = 6 hrs. succeeding blocks = 6. 10*6 = 60.
    // 7PM is past 18:15 so overnight triggers. +200.
    // Total = 310.

    double due = BillingEngine.calculateDue(timeIn, timeOut, config);
    expect(due, 310.0);
  });
}
