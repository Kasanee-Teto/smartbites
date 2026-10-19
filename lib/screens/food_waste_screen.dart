// Owner: Edbert | FR: FR-24, FR-25, FR-33, FR-34
// Design: stitch_smartbites_meal_budget_planner/smartbites_air_food_waste/code.html

import 'package:budget_bites/models/waste_record.dart';
import 'package:flutter/material.dart';

class FoodWasteScreen extends StatelessWidget {
  final List<WasteRecord> records;
  final ValueChanged<WasteRecord>? onAddRecord;
  final ValueChanged<String>? onDeleteRecord;

  const FoodWasteScreen({
    super.key,
    this.records = const [],
    this.onAddRecord,
    this.onDeleteRecord,
  });

  @override
  Widget build(BuildContext context) {
    // TODO(Edbert): Implement food waste log, reason tags, loss calculation, and SDG 12.3 summary.
    return const Scaffold(
      body: Center(
        child: Text('FoodWasteScreen - Edbert (Food Waste)'),
      ),
    );
  }
}
