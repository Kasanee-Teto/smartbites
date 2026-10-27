// Owner: Gilbert | FR: FR-14, FR-15, FR-16, FR-17
// Design: stitch_smartbites_meal_budget_planner/smartbites_belanja_pantry/code.html

import 'package:budget_bites/models/grocery_item.dart';
import 'package:flutter/material.dart';

class GroceryScreen extends StatelessWidget {
  final List<GroceryItem> items;
  final int weeklyBudget;
  final ValueChanged<String>? onToggleItem;
  final ValueChanged<GroceryItem>? onAddItem;
  final ValueChanged<String>? onDeleteItem;
  final VoidCallback? onClearChecked;

  const GroceryScreen({
    super.key,
    this.items = const [],
    this.weeklyBudget = 300000,
    this.onToggleItem,
    this.onAddItem,
    this.onDeleteItem,
    this.onClearChecked,
  });

  @override
  Widget build(BuildContext context) {
    // TODO(Gilbert): Implement shopping list checklist, categories, and spend summary.
    return const Scaffold(
      body: Center(
        child: Text('GroceryScreen - Gilbert (Belanja)'),
      ),
    );
  }
}
