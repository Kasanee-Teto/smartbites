// Owner: Edbert | FR: FR-22, FR-31

import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/widgets/status_badge.dart';
import 'package:flutter/material.dart';

class WaterProgressCard extends StatelessWidget {
  const WaterProgressCard({
    required this.currentMl,
    required this.targetMl,
    super.key,
    this.onAdd,
  });

  static const List<int> quickAmounts = [150, 250, 500];

  final int currentMl;
  final int targetMl;
  final ValueChanged<int>? onAdd;

  double get _progress {
    if (targetMl <= 0) return 0;
    return (currentMl / targetMl).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final waterColor = colorScheme.tertiary;
    final reached = targetMl > 0 && currentMl >= targetMl;
    final remaining = targetMl - currentMl;
    final percent = (_progress * 100).round();
    final add = onAdd;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop, color: waterColor),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    'Air Hari Ini',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (reached)
                  const StatusBadge(
                    label: 'Target tercapai',
                    icon: Icons.check_circle_outline,
                    type: StatusBadgeType.success,
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$currentMl',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: waterColor,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  TextSpan(
                    text: ' / $targetMl ml',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                color: waterColor,
                backgroundColor: waterColor.withAlpha(38),
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    reached
                        ? 'Kerja bagus, tetap terhidrasi!'
                        : 'Sisa $remaining ml lagi',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text('$percent%', style: theme.textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                for (var i = 0; i < quickAmounts.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppConstants.spaceSm),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: waterColor.withAlpha(30),
                        foregroundColor: waterColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceXs,
                        ),
                      ),
                      onPressed: add == null
                          ? null
                          : () => add(quickAmounts[i]),
                      child: Text('+${quickAmounts[i]} ml'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
