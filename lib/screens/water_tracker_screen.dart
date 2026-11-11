// Owner: Edbert | FR: FR-22, FR-23, FR-31

import 'dart:math' as math;

import 'package:budget_bites/models/hydration_reminder.dart';
import 'package:budget_bites/models/water_record.dart';
import 'package:budget_bites/screens/hydration_settings_screen.dart';
import 'package:budget_bites/screens/hydration_stats_screen.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/hydration.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/drink_category_icon.dart';
import 'package:budget_bites/widgets/drink_editor_sheet.dart';
import 'package:budget_bites/widgets/list_tile_spacing.dart';
import 'package:flutter/material.dart';

class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({
    super.key,
    this.dailyTargetMl = AppConstants.defaultWaterTargetMl,
    this.currentWaterMl,
    this.records = const [],
    this.onAddWater,
    this.onAddDrink,
    this.onEditDrink,
    this.onDeleteRecord,
    this.reminder = const HydrationReminder(),
    this.onReminderChanged,
    this.onGoalChanged,
  });

  final int dailyTargetMl;
  final int? currentWaterMl;
  final List<WaterRecord> records;
  final ValueChanged<int>? onAddWater;
  final void Function(DrinkCategory, int)? onAddDrink;
  final ValueChanged<WaterRecord>? onEditDrink;
  final ValueChanged<String>? onDeleteRecord;
  final HydrationReminder reminder;
  final ValueChanged<HydrationReminder>? onReminderChanged;
  final ValueChanged<int>? onGoalChanged;

  void _add(DrinkCategory category, int volume) {
    if (onAddDrink case final add?) {
      add(category, volume);
    } else if (category == DrinkCategory.water) {
      onAddWater?.call(volume);
    }
  }

  Future<void> _openEditor(BuildContext context, {WaterRecord? record}) async {
    final result =
        await showModalBottomSheet<({DrinkCategory category, int volume})>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => DrinkEditorSheet(record: record),
        );
    if (!context.mounted || result == null) return;
    if (record == null) {
      _add(result.category, result.volume);
    } else {
      onEditDrink?.call(
        WaterRecord(
          id: record.id,
          time: record.time,
          category: result.category,
          amountMl: result.volume,
        ),
      );
    }
  }

  Future<void> _openSettings(BuildContext context) async {
    final result = await Navigator.of(context)
        .push<({int goal, HydrationReminder settings})>(
          MaterialPageRoute(
            builder: (_) => HydrationSettingsScreen(
              goal: dailyTargetMl,
              settings: reminder,
            ),
          ),
        );
    if (!context.mounted || result == null) return;
    onReminderChanged?.call(result.settings);
    if (result.goal != dailyTargetMl) onGoalChanged?.call(result.goal);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = drinksOn(records, now).toList()
      ..sort((a, b) {
        final timestampOrder = b.time.compareTo(a.time);
        return timestampOrder == 0 ? b.id.compareTo(a.id) : timestampOrder;
      });
    final score = records.isEmpty && currentWaterMl != null
        ? currentWaterMl!.toDouble()
        : hydrationScore(today);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final showWarning = today.any((drink) => drink.category.creditPercent < 0);
    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        _HydrationGauge(score: score, goal: dailyTargetMl),
        if (showWarning)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Icon(Icons.info_outline, color: colors.onErrorContainer),
                  Expanded(
                    child: Text(
                      'Skor hidrasi aplikasi berkurang sebesar 50% dari volume wine dan alkohol yang dicatat.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        _QuickDrinks(
          canAddWater: onAddDrink != null || onAddWater != null,
          canAddOthers: onAddDrink != null,
          onAdd: _add,
          onCustom: onAddDrink == null ? null : () => _openEditor(context),
        ),
      ],
    );
    final history = _DrinkHistory(
      records: today,
      onEdit: onEditDrink == null
          ? null
          : (record) => _openEditor(context, record: record),
      onDelete: onDeleteRecord,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
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
                spacing: 16,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hidrasi', style: theme.textTheme.headlineSmall),
                          Text(
                            'Hari ini · ${mealDateLabel(now)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push<void>(
                              MaterialPageRoute(
                                builder: (_) => HydrationStatsScreen(
                                  records: records,
                                  goal: dailyTargetMl,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.bar_chart_outlined),
                            label: const Text('Statistik'),
                          ),
                          OutlinedButton.icon(
                            onPressed:
                                onReminderChanged == null &&
                                    onGoalChanged == null
                                ? null
                                : () => _openSettings(context),
                            icon: Icon(
                              reminder.enabled
                                  ? Icons.notifications_active_outlined
                                  : Icons.notifications_outlined,
                            ),
                            label: const Text('Pengingat'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!wide) ...[
                    controls,
                    history,
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        Expanded(flex: 6, child: controls),
                        Expanded(flex: 5, child: history),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HydrationGauge extends StatelessWidget {
  const _HydrationGauge({required this.score, required this.goal});

  final double score;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final ratio = goal > 0 ? score / goal : 0.0;
    final progress = ratio.clamp(0.0, 1.0);
    final scoreColor = score < 0 ? colors.error : colors.tertiary;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Skor hidrasi', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox.square(
              dimension: 188,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    color: colors.tertiary,
                    backgroundColor: colors.tertiary.withAlpha(45),
                    semanticsLabel: 'Target hidrasi',
                  ),
                  Positioned.fill(
                    left: 10,
                    right: 10,
                    top: 10,
                    bottom: 10,
                    child: ClipOval(
                      child: CustomPaint(
                        painter: _WaterFill(
                          progress: progress,
                          tint: colors.tertiary,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          children: [
                            Icon(Icons.water_drop_outlined, color: scoreColor),
                            Text(
                              formatHydration(score),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: scoreColor,
                                fontSize: 38,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'dari $goal ml',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              score >= goal
                  ? 'Target tercapai'
                  : 'Sisa ${formatHydration(goal - score)} ml menuju target',
              style: theme.textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterFill extends CustomPainter {
  const _WaterFill({required this.progress, required this.tint});

  final double progress;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = tint.withAlpha(18));
    if (progress == 0) return;
    final waterline = size.height * (1 - progress);
    final amplitude = 10 * math.sin(math.pi * progress);
    for (final direction in [-1, 1]) {
      final path = Path()
        ..moveTo(0, waterline)
        ..cubicTo(
          size.width * 0.32,
          waterline - 3 * amplitude * direction,
          size.width * 0.68,
          waterline + 3 * amplitude * direction,
          size.width,
          waterline,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = tint.withAlpha(40));
    }
  }

  @override
  bool shouldRepaint(_WaterFill oldDelegate) =>
      progress != oldDelegate.progress || tint != oldDelegate.tint;
}

class _QuickDrinks extends StatelessWidget {
  const _QuickDrinks({
    required this.canAddWater,
    required this.canAddOthers,
    required this.onAdd,
    this.onCustom,
  });

  final bool canAddWater;
  final bool canAddOthers;
  final void Function(DrinkCategory, int) onAdd;
  final VoidCallback? onCustom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text('Catat minuman', style: theme.textTheme.titleMedium),
            if (onCustom != null)
              TextButton.icon(
                onPressed: onCustom,
                icon: const Icon(Icons.tune),
                label: const Text('Atur porsi'),
              ),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = AppConstants.spaceSm + AppConstants.spaceXs;
            final minWidth = MediaQuery.textScalerOf(context).scale(110);
            final columns =
                ((constraints.maxWidth + spacing) / (minWidth + spacing))
                    .floor()
                    .clamp(1, 4);
            final width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final category in DrinkCategory.values)
                  SizedBox(
                    width: width,
                    child: OutlinedButton(
                      onPressed:
                          (category == DrinkCategory.water
                              ? canAddWater
                              : canAddOthers)
                          ? () => onAdd(category, category.defaultMl)
                          : null,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.standard,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerLowest,
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: AlignmentDirectional.centerStart,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DrinkCategoryIcon(category: category),
                            const SizedBox(height: 8),
                            Text(
                              category.label,
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+${category.defaultMl} ml',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

enum _DrinkAction { edit, delete }

class _DrinkHistory extends StatelessWidget {
  const _DrinkHistory({required this.records, this.onEdit, this.onDelete});

  final List<WaterRecord> records;
  final ValueChanged<WaterRecord>? onEdit;
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text('Riwayat hari ini', style: theme.textTheme.titleMedium),
        if (records.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                spacing: 8,
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    size: 36,
                    color: theme.colorScheme.tertiary,
                  ),
                  const Text(
                    'Belum ada catatan minum hari ini',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Pilih minuman untuk mulai mencatat.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        for (final record in records)
          Card(
            key: ValueKey(record.id),
            margin: EdgeInsets.zero,
            child: ListTileSpacing(
              child: ListTile(
                leading: DrinkCategoryIcon(category: record.category),
                title: Text(record.category.label),
                subtitle: Text(
                  TimeOfDay.fromDateTime(record.time).format(context),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${record.amountMl} ml',
                      style: theme.textTheme.labelLarge,
                    ),
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<_DrinkAction>(
                        tooltip: 'Opsi catatan',
                        onSelected: (action) {
                          switch (action) {
                            case _DrinkAction.edit:
                              onEdit?.call(record);
                            case _DrinkAction.delete:
                              onDelete?.call(record.id);
                          }
                        },
                        itemBuilder: (_) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: _DrinkAction.edit,
                              child: Text('Ubah'),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: _DrinkAction.delete,
                              child: Text('Hapus'),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
