// Owner: Louis | FR: FR-04, FR-05, FR-06, FR-36
// Design: stitch_smartbites_meal_budget_planner/smartbites_beranda/code.html

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/user_profile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final UserProfile profile;
  final List<Meal> todayMeals;
  final List<bool> todayEaten;
  final int totalWeeklyBudget;
  final int currentSpent;
  final int todayWaterMl;
  final int streakDays;
  final ValueChanged<int>? onQuickWaterAdd;
  final void Function(int slotIndex, bool eaten)? onToggleMealEaten;
  final VoidCallback? onOpenMealPlan;
  final VoidCallback? onOpenInsight;
  final VoidCallback? onOpenStreak;

  const HomeScreen({
    super.key,
    required this.profile,
    this.todayMeals = const [],
    this.todayEaten = const [],
    this.totalWeeklyBudget = 300000,
    this.currentSpent = 0,
    this.todayWaterMl = 0,
    this.streakDays = 0,
    this.onQuickWaterAdd,
    this.onToggleMealEaten,
    this.onOpenMealPlan,
    this.onOpenInsight,
    this.onOpenStreak,
  });

  @override
  Widget build(BuildContext context) {
    // TODO(Louis): Implement full Beranda dashboard layout in Step 3.
    return const Scaffold(
      body: Center(
        child: Text('HomeScreen - Louis (Beranda)'),
      ),
    );
  }
}
