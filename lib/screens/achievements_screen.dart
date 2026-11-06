// Owner: Edbert | FR: FR-37, FR-38, FR-39
// Design: stitch_smartbites_meal_budget_planner/smartbites_profil_pencapaian/code.html

import 'dart:math' as math;

import 'package:budget_bites/models/achievement.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/badge_rules.dart';
import 'package:budget_bites/widgets/badge_tile.dart';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  final List<Achievement> achievements;
  final int currentStreak;
  final VoidCallback? onBack;

  const AchievementsScreen({
    super.key,
    this.achievements = const [],
    this.currentStreak = 0,
    this.onBack,
  });

  int get _unlockedCount => achievements.where((a) => a.isUnlocked).length;

  /// Badge streak terdekat yang masih terkunci (3 hari, lalu 7 hari).
  Achievement? get _nextStreakBadge {
    final locked = achievements
        .where(
          (a) =>
              !a.isUnlocked &&
              (a.id == BadgeRules.streak3 || a.id == BadgeRules.streak7),
        )
        .toList()
      ..sort((a, b) => a.target.compareTo(b.target));
    return locked.isEmpty ? null : locked.first;
  }

  /// Bahasa ramah, tanpa kata yang menyalahkan (PRD bagian 6.2).
  String _streakMessage() {
    if (currentStreak <= 0) {
      return 'Mulai catatan hari ini, satu ketukan sudah cukup.';
    }
    final next = _nextStreakBadge;
    if (next == null) return 'Semua badge streak sudah terbuka!';
    final remaining = next.target - currentStreak;
    if (remaining <= 0) return 'Terus semangat, kamu hampir sampai!';
    return '$remaining hari lagi menuju ${next.title}';
  }

  Widget _buildSummary(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final total = achievements.length;
    final unlocked = _unlockedCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 32.0,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Text(
                  '$currentStreak hari',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceXs),
            Text(_streakMessage(), style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppConstants.spaceMd),
            Text(
              '$unlocked dari $total badge terbuka',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: AppConstants.spaceSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              child: LinearProgressIndicator(
                value: total == 0 ? 0.0 : unlocked / total,
                minHeight: 8.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showBack = onBack != null || Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBack ? BackButton(onPressed: onBack) : null,
        title: const Text('Pencapaian'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = math.min(
            constraints.maxWidth - AppConstants.spaceMd * 2,
            AppConstants.maxContentWidth,
          );
          final columns = (contentWidth / 180.0).floor().clamp(2, 4).toInt();
          final tileWidth =
              (contentWidth - AppConstants.spaceMd * (columns - 1)) / columns;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummary(theme),
                    const SizedBox(height: AppConstants.spaceMd),
                    if (achievements.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spaceLg),
                          child: Text(
                            'Belum ada badge. Mulai mencatat untuk membukanya.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: AppConstants.spaceMd,
                        runSpacing: AppConstants.spaceMd,
                        children: [
                          for (final badge in achievements)
                            SizedBox(
                              width: tileWidth,
                              child: BadgeTile(achievement: badge),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}