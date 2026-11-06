// Owner: Jessica | Per-serving nutrition totals and user-defined goals.

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/planned_meal.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/widgets/option_icon.dart';
import 'package:flutter/material.dart';

class NutritionSummary extends StatelessWidget {
  const NutritionSummary({
    required this.entries,
    required this.meals,
    required this.goals,
    this.focus = NutritionFocus.general,
    this.allNutrients = false,
    super.key,
  });
  final List<PlannedMeal> entries;
  final List<Meal> meals;
  final Map<Nutrient, double> goals;
  final NutritionFocus focus;
  final bool allNutrients;

  @override
  Widget build(BuildContext context) {
    final catalog = {for (final m in meals) m.id: m};
    const energy = [
      Nutrient.calories,
      Nutrient.sugar,
      Nutrient.fat,
      Nutrient.carbs,
      Nutrient.saturatedFat,
    ];
    final nutrients = allNutrients && focus == NutritionFocus.general
        ? [
            Nutrient.protein,
            Nutrient.fiber,
            Nutrient.sodium,
            Nutrient.cholesterol,
          ]
        : focusNutrients(focus);
    double? goalFor(Nutrient n) {
      final goal = goals[n];
      return goal != null && goal.isFinite && goal > 0 ? goal : null;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan gizi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (allNutrients) ...[
              ExpansionTile(
                key: PageStorageKey<String>('energy_${focus.name}'),
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: true,
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  'Energi & makro',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                children: [
                  const SizedBox(height: 4),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final minimumWidth = MediaQuery.textScalerOf(context)
                          .scale(90);
                      final columns = (constraints.maxWidth / minimumWidth)
                          .floor()
                          .clamp(1, 5);
                      final width =
                          (constraints.maxWidth - (columns - 1) * 8) / columns;
                      return Wrap(
                        spacing: 6,
                        runSpacing: 16,
                        children: [
                          for (final nutrient in energy)
                            SizedBox(
                              width: width,
                              child: _NutrientRing(
                                nutrient: nutrient,
                                total: sumNutrient(entries, catalog, nutrient),
                                goal: goalFor(nutrient),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ],
            if (allNutrients)
              ExpansionTile(
                key: PageStorageKey<String>('wellness_${focus.name}'),
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: true,
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  focus == NutritionFocus.general
                      ? 'Protein, serat & mineral'
                      : 'Fokus ${focus.label}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                children: [
                  if (goals.isEmpty)
                    const Padding(padding: EdgeInsets.only(bottom: 8)),
                  for (final nutrient in nutrients)
                    _NutrientRow(
                      nutrient: nutrient,
                      total: sumNutrient(entries, catalog, nutrient),
                      goal: goalFor(nutrient),
                    ),
                ],
              )
            else
              for (final nutrient in nutrients)
                _NutrientRow(
                  nutrient: nutrient,
                  total: sumNutrient(entries, catalog, nutrient),
                  goal: goalFor(nutrient),
                ),
            if (allNutrients)
              ExpansionTile(
                key: PageStorageKey<String>('other_nutrients_${focus.name}'),
                tilePadding: EdgeInsets.zero,
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  'Rincian nutrisi lainnya',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                children: [
                  for (final nutrient in Nutrient.values.where(
                    (n) => !nutrients.contains(n) && !energy.contains(n),
                  ))
                    _NutrientRow(
                      nutrient: nutrient,
                      total: sumNutrient(entries, catalog, nutrient),
                      goal: goalFor(nutrient),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

IconData _nutrientIcon(Nutrient nutrient) => switch (nutrient) {
  Nutrient.calories => Icons.local_fire_department_rounded,
  Nutrient.protein => Icons.bolt_rounded,
  Nutrient.carbs => Icons.grain_rounded,
  Nutrient.fat => Icons.opacity,
  Nutrient.saturatedFat || Nutrient.transFat => Icons.water_drop_rounded,
  Nutrient.fiber => Icons.eco_rounded,
  Nutrient.sugar || Nutrient.addedSugar => Icons.bubble_chart_rounded,
  Nutrient.sodium => Icons.scatter_plot_rounded,
  Nutrient.cholesterol => Icons.favorite_outline,
  _ => Icons.spa_outlined,
};

Color _nutrientColor(Nutrient nutrient) => switch (nutrient) {
  Nutrient.calories || Nutrient.protein => Colors.orange.shade800,
  Nutrient.carbs || Nutrient.fat => Colors.amber.shade800,
  Nutrient.sugar ||
  Nutrient.addedSugar ||
  Nutrient.sodium => Colors.blue.shade700,
  Nutrient.cholesterol => Colors.red.shade700,
  _ => Colors.green.shade700,
};

class _NutrientRing extends StatelessWidget {
  const _NutrientRing({required this.nutrient, required this.total, this.goal});
  final Nutrient nutrient;
  final NutrientTotal total;
  final double? goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final known = total.known > 0 || total.count == 0;
    final amount = known
        ? '${total.isComplete ? '' : '≥ '}${nutrientNumber(total.value)} ${nutrient.unit}'
        : 'Belum tersedia';
    final hasProgress = goal != null && total.isComplete;
    final color = nutrient.isLimit && goal != null && total.value > goal!
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    return Semantics(
      label:
          '${nutrient.label}: $amount. ${goal == null ? 'Tanpa target' : 'Target atau batas ${nutrientNumber(goal!)} ${nutrient.unit}'}. '
          '${total.isComplete ? '' : 'Data belum lengkap'}',
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: hasProgress
                          ? (total.value / goal!).clamp(0.0, 1.0)
                          : 0,
                      strokeWidth: 4,
                      color: color,
                      backgroundColor: theme.colorScheme.outlineVariant
                          .withAlpha(110),
                    ),
                  ),
                  Icon(
                    _nutrientIcon(nutrient),
                    size: 25,
                    color: _nutrientColor(nutrient),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nutrient.label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              !total.isComplete
                  ? 'Data ${total.known}/${total.count}'
                  : goal == null
                  ? 'Tanpa target'
                  : '/ ${nutrientNumber(goal!)} ${nutrient.unit}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({required this.nutrient, required this.total, this.goal});
  final Nutrient nutrient;
  final NutrientTotal total;
  final double? goal;

  @override
  Widget build(BuildContext context) {
    final hasValue = total.known > 0 || total.count == 0;
    final prefix = total.isComplete ? '' : '≥ ';
    final text = hasValue
        ? '$prefix${nutrientNumber(total.value)} ${nutrient.unit}'
        : 'Belum tersedia';
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OptionIcon(
                icon: _nutrientIcon(nutrient),
                color: _nutrientColor(nutrient),
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(nutrient.label, style: theme.textTheme.titleSmall),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          if (!total.isComplete)
            Text('Data tersedia: ${total.known}/${total.count} menu'),
          if (goal != null) ...[
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: (total.value / goal!).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: nutrient.isLimit && total.value > goal!
                  ? theme.colorScheme.secondary
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              '${nutrient.isLimit ? 'Batas' : 'Target'} pilihan: '
              '${nutrientNumber(goal!)} ${nutrient.unit} • '
              '${_status()}',
            ),
          ],
        ],
      ),
    );
  }

  String _status() {
    if (total.count == 0) return 'Belum dicatat';
    if (nutrient.isLimit && total.value > goal!) {
      return 'Melebihi batas pilihan';
    }
    if (!total.isComplete) return 'Data belum lengkap';
    if (nutrient.isLimit) return 'Dalam batas pilihan';
    return total.value >= goal! ? 'Target pilihan tercapai' : 'Belum tercapai';
  }
}

class NutritionTrend extends StatelessWidget {
  const NutritionTrend({
    required this.entries,
    required this.meals,
    required this.date,
    super.key,
  });
  final List<PlannedMeal> entries;
  final List<Meal> meals;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final catalog = {for (final m in meals) m.id: m};
    final monday = mondayOf(date);
    final planned = <double>[];
    final eaten = <double>[];
    for (var d = 0; d < 7; d++) {
      final daily = mealsOnDay(entries, calendarDay(monday, d));
      planned.add(sumNutrient(daily, catalog, Nutrient.calories).value);
      eaten.add(
        sumNutrient(
          daily.where((e) => e.isEaten),
          catalog,
          Nutrient.calories,
        ).value,
      );
    }
    final maxValue = planned.fold<double>(1, (a, b) => a > b ? a : b);
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tren energi minggu ini',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text('terang: rencana • hijau: dimakan'),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var d = 0; d < 7; d++)
                  Expanded(
                    child: Semantics(
                      label:
                          '${shortDays[d]}: rencana ${planned[d].round()} kkal, '
                          'dimakan ${eaten[d].round()} kkal',
                      child: Column(
                        children: [
                          SizedBox(
                            height: 100,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 9,
                                    height: 2 + planned[d] / maxValue * 96,
                                    color: colors.primaryContainer.withAlpha(
                                      80,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Container(
                                    width: 9,
                                    height: 2 + eaten[d] / maxValue * 96,
                                    color: colors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(shortDays[d], maxLines: 1),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
