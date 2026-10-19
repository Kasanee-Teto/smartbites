// Owner: Jesseca | FR: FR-11, FR-12
// Design: stitch_smartbites_meal_budget_planner/smartbites_detail_resep_alergi/code.html

import 'package:budget_bites/models/meal.dart';
import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal? meal;
  final List<String> userAllergies;
  final ValueChanged<Meal>? onAddToGrocery;
  final VoidCallback? onBack;

  const MealDetailScreen({
    super.key,
    this.meal,
    this.userAllergies = const [],
    this.onAddToGrocery,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // TODO(Jesseca): Implement meal recipe detail, allergy warning, and ingredients list.
    return const Scaffold(
      body: Center(
        child: Text('MealDetailScreen - Jesseca (Detail Resep)'),
      ),
    );
  }
}
