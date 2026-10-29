// Owner: Edbert | FR: FR-37, FR-38, FR-39
// Design: stitch_smartbites_meal_budget_planner/smartbites_profil_pencapaian/code.html

import 'package:budget_bites/models/achievement.dart';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({
    super.key,
    this.achievements = const [],
    this.currentStreak = 0,
    this.onBack,
  });
  final List<Achievement> achievements;
  final int currentStreak;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    // TODO(Edbert): Implement badge grid, streak milestones, and unlock
    // progress bars.
    return const Scaffold(
      body: Center(child: Text('AchievementsScreen - Edbert (Pencapaian)')),
    );
  }
}
