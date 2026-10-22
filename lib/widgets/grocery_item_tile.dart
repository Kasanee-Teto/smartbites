// Owner: Gilbert | FR: FR-14, FR-16
// Design: stitch_smartbites_meal_budget_planner/smartbites_belanja_pantry/code.html

import 'package:budget_bites/models/grocery_item.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:flutter/material.dart';

/// Helper to format quantities like 1.0 -> 1, 2.5 -> 2.5.
String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toInt().toString();
  }
  return quantity.toString();
}

/// A reusable grocery item tile matching the Stitch HTML design
/// (`smartbites_belanja_pantry/code.html`) with swipe-to-delete (FR-14, FR-16).
class GroceryItemTile extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onToggle;

  /// Swipe-to-delete is disabled when null.
  final VoidCallback? onDismissed;

  const GroceryItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isChecked = item.isChecked;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: 5,
      ),
      child: Dismissible(
        key: Key(item.id),
        direction: onDismissed == null
            ? DismissDirection.none
            : DismissDirection.endToStart,
        onDismissed: (_) => onDismissed?.call(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hapus',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onError,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.delete_outline,
                color: colorScheme.onError,
                size: 20,
              ),
            ],
          ),
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: isChecked
              ? colorScheme.surfaceContainerLow
              : colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Checkbox(
                      value: isChecked,
                      onChanged: (_) => onToggle(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            decoration:
                                isChecked ? TextDecoration.lineThrough : null,
                            color: isChecked
                                ? colorScheme.outline
                                : colorScheme.onSurface,
                            fontWeight:
                                isChecked ? FontWeight.w500 : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer
                                    .withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusSm,
                                ),
                              ),
                              child: Text(
                                '${_formatQuantity(item.quantity)} ${item.unit}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Pasar Tradisional',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatRupiah(item.price),
                        style: textTheme.labelLarge?.copyWith(
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked
                              ? colorScheme.outline
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isChecked ? 'Selesai' : 'Tersedia',
                        style: textTheme.labelSmall?.copyWith(
                          color: isChecked
                              ? colorScheme.primary
                              : colorScheme.outline,
                          fontWeight:
                              isChecked ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
