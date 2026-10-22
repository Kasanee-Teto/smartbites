// Owner: Gilbert | FR: FR-07
// Design: stitch_smartbites_meal_budget_planner/smartbites_beranda/code.html

import 'package:flutter/material.dart';

class InsightScreen extends StatelessWidget {
  final int currentSpent;
  final int weeklyBudget;
  final VoidCallback? onBack;

  const InsightScreen({
    super.key,
    this.currentSpent = 0,
    this.weeklyBudget = 300000,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // TODO(Gilbert): Implement spending breakdown, budget burn rate, and shopping tips.
    return const Scaffold(
      body: Center(
        child: Text('InsightScreen - Gilbert (Insight Nutrisi & Hemat)'),
      ),
    );
  }
}
