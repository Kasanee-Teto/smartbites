// Owner: Gilbert | FR: FR-14, FR-16

import 'package:budget_bites/models/grocery_item.dart';
import 'package:flutter/material.dart';

/// Formats integer amount into Indonesian Rupiah format: e.g. 'Rp 5.000', 'Rp 28.000', 'Rp 300.000'.
String formatRupiah(int amount) {
  if (amount == 0) return 'Rp 0';
  final isNegative = amount < 0;
  final absAmount = amount.abs().toString();
  final buffer = StringBuffer();
  final length = absAmount.length;
  for (int i = 0; i < length; i++) {
    if (i > 0 && (length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(absAmount[i]);
  }
  return '${isNegative ? '-Rp ' : 'Rp '}$buffer';
}

/// Helper to format quantities like 1.0 -> 1, 2.5 -> 2.5.
String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toInt().toString();
  }
  return quantity.toString();
}

/// A reusable grocery item tile representing a single grocery row with swipe-to-delete.
class GroceryItemTile extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onToggle;
  final VoidCallback onDismissed;

  const GroceryItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.delete_outline,
            color: colorScheme.onError,
          ),
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: item.isChecked
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
              : colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: Checkbox(
              value: item.isChecked,
              onChanged: (_) => onToggle(),
            ),
            title: Text(
              item.name,
              style: textTheme.bodyLarge?.copyWith(
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked
                    ? colorScheme.outline
                    : colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '${_formatQuantity(item.quantity)} ${item.unit}',
              style: textTheme.bodyMedium?.copyWith(
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked
                    ? colorScheme.outline
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Text(
              formatRupiah(item.price),
              style: textTheme.titleSmall?.copyWith(
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked
                    ? colorScheme.outline
                    : colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: onToggle,
          ),
        ),
      ),
    );
  }
}
