// Owner: Edbert | FR: FR-22, FR-23, FR-31
// Design: stitch_smartbites_meal_budget_planner/smartbites_air_food_waste/code.html

import 'package:budget_bites/models/water_record.dart';
import 'package:flutter/material.dart';

class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({
    super.key,
    this.dailyTargetMl = 2000,
    this.currentWaterMl = 0,
    this.records = const [],
    this.onAddWater,
    this.onDeleteRecord,
  });
  final int dailyTargetMl;
  final int currentWaterMl;
  final List<WaterRecord> records;
  final ValueChanged<int>? onAddWater;
  final ValueChanged<String>? onDeleteRecord;

  @override
  Widget build(BuildContext context) {
    // TODO(Edbert): Implement hydration gauge, quick-add buttons (+150, +250,
    // +500), and history list.
    return const Scaffold(
      body: Center(child: Text('WaterTrackerScreen - Edbert (Air)')),
    );
  }
}
