import 'dart:math' as math;

import 'package:budget_bites/models/water_record.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/hydration.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/drink_category_icon.dart';
import 'package:flutter/material.dart';

class HydrationStatsScreen extends StatelessWidget {
  const HydrationStatsScreen({
    required this.records,
    required this.goal,
    super.key,
  });

  final List<WaterRecord> records;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final today = calendarDay(DateTime.now());
    final monday = mondayOf(today);
    final nextMonday = calendarDay(monday, 7);
    final weekly = records.where((record) {
      return !record.time.isBefore(monday) && record.time.isBefore(nextMonday);
    }).toList();
    final days = [for (var i = 0; i < 7; i++) calendarDay(monday, i)];
    final scores = [
      for (final day in days) hydrationScore(drinksOn(weekly, day)),
    ];
    final volumes = <DrinkCategory, int>{};
    for (final drink in weekly) {
      volumes.update(
        drink.category,
        (amount) => amount + drink.amountMl,
        ifAbsent: () => drink.amountMl,
      );
    }
    final streak = hydrationStreak(records, today, goal);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final daily = _StatsCard(
      title: 'Skor hidrasi per hari',
      subtitle:
          '${mealDateLabel(days.first)} – ${mealDateLabel(days.last)}\n'
          'Target $goal ml per hari',
      child: _WeeklyBars(
        scores: scores,
        todayIndex: today.weekday - 1,
        goal: goal,
      ),
    );
    final breakdown = _StatsCard(
      title: 'Jenis minuman',
      subtitle: 'Volume yang dicatat minggu ini',
      child: _DrinkBreakdown(volumes: volumes),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik hidrasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide =
                    windowSizeFor(constraints.maxWidth) == WindowSize.expanded;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(
                            Icons.local_fire_department_outlined,
                            color: colors.secondary,
                          ),
                          label: Text(
                            '$streak hari berturut-turut mencapai target',
                          ),
                        ),
                        Chip(
                          avatar: Icon(
                            Icons.local_drink_outlined,
                            color: colors.tertiary,
                          ),
                          label: Text('${weekly.length} minuman minggu ini'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Expanded(child: daily),
                          Expanded(child: breakdown),
                        ],
                      )
                    else ...[
                      daily,
                      const SizedBox(height: 12),
                      breakdown,
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({
    required this.scores,
    required this.todayIndex,
    required this.goal,
  });

  final List<double> scores;
  final int todayIndex;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final high = scores.fold(goal.toDouble(), math.max);
    final low = scores.fold<double>(0, math.min);
    final range = math.max(high - low, 1);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        for (var i = 0; i < scores.length; i++)
          Expanded(
            child: Semantics(
              label: '${shortDays[i]}, ${formatHydration(scores[i])} ml',
              excludeSemantics: true,
              child: Column(
                children: [
                  SizedBox(
                    height: 136,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final baseline = constraints.maxHeight * high / range;
                        final height =
                            constraints.maxHeight * scores[i].abs() / range;
                        final color = scores[i] < 0
                            ? theme.colorScheme.error
                            : i == todayIndex
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.tertiary.withAlpha(125);
                        return Stack(
                          children: [
                            if (goal > 0)
                              Positioned(
                                left: 0,
                                right: 0,
                                top:
                                    (baseline -
                                            constraints.maxHeight *
                                                goal /
                                                range)
                                        .clamp(0.0, constraints.maxHeight - 1),
                                child: Divider(
                                  height: 1,
                                  color: theme.colorScheme.tertiary.withAlpha(
                                    95,
                                  ),
                                ),
                              ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: baseline.clamp(
                                0.0,
                                constraints.maxHeight - 1,
                              ),
                              child: Divider(
                                height: 1,
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            if (height > 0)
                              Positioned(
                                left: 5,
                                right: 5,
                                top: scores[i] < 0
                                    ? baseline
                                    : baseline - height,
                                height: height,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      shortDays[i],
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatHydration(scores[i]),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DrinkBreakdown extends StatelessWidget {
  const _DrinkBreakdown({required this.volumes});

  final Map<DrinkCategory, int> volumes;

  @override
  Widget build(BuildContext context) {
    if (volumes.isEmpty) {
      return const Text('Belum ada minuman tercatat minggu ini.');
    }
    final theme = Theme.of(context);
    final total = volumes.values.fold(0, (sum, volume) => sum + volume);
    final slices = [
      for (final category in DrinkCategory.values)
        if (volumes.containsKey(category))
          (
            color: category.color(theme.colorScheme),
            fraction: volumes[category]! / total,
          ),
    ];
    return Column(
      children: [
        SizedBox.square(
          dimension: 144,
          child: CustomPaint(painter: _PiePainter(slices)),
        ),
        const SizedBox(height: 12),
        for (final category in DrinkCategory.values)
          if (volumes[category] case final volume?)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    color: category.color(theme.colorScheme),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(category.label)),
                  Text('$volume ml · ${(volume / total * 100).round()}%'),
                ],
              ),
            ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.slices);

  final List<({Color color, double fraction})> slices;

  @override
  void paint(Canvas canvas, Size size) {
    var start = -math.pi / 2;
    final paint = Paint();
    for (final slice in slices) {
      final sweep = slice.fraction * math.pi * 2;
      canvas.drawArc(
        Offset.zero & size,
        start,
        sweep,
        true,
        paint..color = slice.color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter oldDelegate) => oldDelegate.slices != slices;
}
