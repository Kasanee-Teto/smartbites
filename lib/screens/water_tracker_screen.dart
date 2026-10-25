// Owner: Edbert | FR: FR-22, FR-23, FR-31
// Design: stitch_smartbites_meal_budget_planner/smartbites_air_food_waste/code.html

import 'package:budget_bites/models/water_record.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/water_progress_card.dart';
import 'package:flutter/material.dart';

class WaterTrackerScreen extends StatelessWidget {
  final int dailyTargetMl;
  final int currentWaterMl;
  final List<WaterRecord> records;
  final ValueChanged<int>? onAddWater;
  final ValueChanged<String>? onDeleteRecord;

  const WaterTrackerScreen({
    super.key,
    this.dailyTargetMl = 2000,
    this.currentWaterMl = 0,
    this.records = const [],
    this.onAddWater,
    this.onDeleteRecord,
  });

  List<WaterRecord> _todayRecords() {
    final today = dateOnly(DateTime.now());
    final list = records.where((r) => dateOnly(r.time) == today).toList();
    list.sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final card = WaterProgressCard(
      currentMl: currentWaterMl,
      targetMl: dailyTargetMl,
      onAdd: onAddWater,
    );
    final history = _WaterHistory(
      records: _todayRecords(),
      onDelete: onDeleteRecord,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            windowSizeFor(constraints.maxWidth) == WindowSize.compact;

        return SingleChildScrollView(

          padding: const EdgeInsets.fromLTRB(
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            96.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        card,
                        const SizedBox(height: AppConstants.spaceMd),
                        history,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: card),
                        const SizedBox(width: AppConstants.spaceMd),
                        Expanded(child: history),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _WaterHistory extends StatelessWidget {
  final List<WaterRecord> records;
  final ValueChanged<String>? onDelete;

  const _WaterHistory({required this.records, this.onDelete});

  String _formatTime(DateTime t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final delete = onDelete;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Riwayat Hari Ini', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppConstants.spaceSm),
        Card(
          child: records.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  child: Column(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: 40.0,
                        color: colorScheme.tertiary.withAlpha(150),
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      Text(
                        'Belum ada catatan minum hari ini',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spaceXs),
                      Text(
                        'Ketuk +250 ml untuk mulai mencatat.',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (final record in records)
                      ListTile(
                        leading: Icon(
                          Icons.water_drop,
                          color: colorScheme.tertiary,
                        ),
                        title: Text('+${record.amountMl} ml'),
                        subtitle: Text(_formatTime(record.time)),
                        trailing: delete == null
                            ? null
                            : IconButton(
                                tooltip: 'Hapus catatan',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => delete(record.id),
                              ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}