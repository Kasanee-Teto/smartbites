// Owner: Jesseca | FR: FR-08, FR-09, FR-10, FR-13
// Design: stitch_smartbites_meal_budget_planner/smartbites_perencana_makan/code.html

import 'package:budget_bites/models/meal.dart';
import 'package:flutter/material.dart';

class MealPlanScreen extends StatelessWidget {
  final List<List<String>> weekPlan;
  final List<List<bool>> eaten;
  final List<Meal> meals;
  final int weeklyBudget;
  final void Function(int dayIndex, int slotIndex, String newMealId)? onSwapMeal;
  final void Function(int dayIndex, int slotIndex)? onDeleteMeal;
  final void Function(int dayIndex, int slotIndex, bool eaten)? onToggleMealEaten;
  final ValueChanged<Meal>? onMealTap;

  const MealPlanScreen({
    super.key,
    this.weekPlan = const [],
    this.eaten = const [],
    this.meals = const [],
    this.weeklyBudget = 300000,
    this.onSwapMeal,
    this.onDeleteMeal,
    this.onToggleMealEaten,
    this.onMealTap,
  });

  @override
  Widget build(BuildContext context) {
    // TODO(Jesseca): Implement meal planner grid, day chips, calorie tracker, and slot cards.
    return const Scaffold(
      body: Center(
        child: Text('MealPlanScreen - Jesseca (Menu)'),
      ),
    );
  }
}
