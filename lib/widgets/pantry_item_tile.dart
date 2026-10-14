// Owner: Gilbert | FR: FR-18, FR-19, FR-20, FR-21

import 'package:budget_bites/models/pantry_item.dart';
import 'package:flutter/material.dart';

/// Enum representing the freshness status of a pantry item based on expiry date.
enum ExpiryStatus { safe, expiringSoon, expired }

/// Indonesian month abbreviations for manual date formatting without the intl package.
const List<String> indonesianMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Formats a [DateTime] into Indonesian date format 'dd MMM yyyy' (e.g., '14 Okt 2026').
String formatExpiryDate(DateTime expiryDate) {
  final day = expiryDate.day.toString().padLeft(2, '0');
  final month = indonesianMonths[expiryDate.month - 1];
  final year = expiryDate.year;
  return '$day $month $year';
}

/// Helper function to determine the expiry status of an item relative to today.
/// - 'expired': expiry is today or past
/// - 'expiringSoon': expiry is within 1 to 3 days
/// - 'safe': expiry is more than 3 days from now
ExpiryStatus getExpiryStatus(DateTime expiryDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
  final difference = exp.difference(today).inDays;

  if (difference <= 0) {
    return ExpiryStatus.expired;
  } else if (difference <= 3) {
    return ExpiryStatus.expiringSoon;
  } else {
    return ExpiryStatus.safe;
  }
}

/// Helper to format quantities: 1.0 -> '1', 2.5 -> '2.5'.
String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toInt().toString();
  }
  return quantity.toString();
}

/// A reusable widget representing a single pantry item row.
class PantryItemTile extends StatelessWidget {
  final PantryItem item;
  final ValueChanged<double> onQuantityChanged;

  const PantryItemTile({
    super.key,
    required this.item,
    required this.onQuantityChanged,
  });

  Widget _buildExpiryBadge(BuildContext context, DateTime expiryDate) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final status = getExpiryStatus(expiryDate);

    final Color backgroundColor;
    final Color textColor;
    final String label;

    switch (status) {
      case ExpiryStatus.safe:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        label = 'Aman';
        break;
      case ExpiryStatus.expiringSoon:
        backgroundColor = isDark
            ? Colors.amber.withValues(alpha: 0.25)
            : Colors.amber.shade100;
        textColor = isDark ? Colors.amber.shade300 : Colors.amber.shade900;
        label = 'Segera habis';
        break;
      case ExpiryStatus.expired:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        label = 'Kedaluwarsa';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Stock progress calculations
    final double maxQuantity = item.minQuantity > 0 ? item.minQuantity * 2 : 1.0;
    final double progressValue = (item.quantity / maxQuantity).clamp(0.0, 1.0);
    final bool isLowStock = item.quantity <= item.minQuantity;

    // Warning color for low stock
    final Color warningColor = Colors.amber.shade800;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Item Name, Expiry Date & Expiry Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kedaluwarsa: ${formatExpiryDate(item.expiryDate)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildExpiryBadge(context, item.expiryDate),
              ],
            ),
            const SizedBox(height: 12),
            // Row 2: Stock Level / Low stock indicator and Quantity Stepper
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: Quantity with Unit & Progress Indicator
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_formatQuantity(item.quantity)} ${item.unit}',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isLowStock ? warningColor : colorScheme.onSurface,
                            ),
                          ),
                          if (isLowStock) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: warningColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Stok menipis',
                                style: textTheme.labelSmall?.copyWith(
                                  color: warningColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 6,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isLowStock ? warningColor : colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right: Stepper (FR-21)
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Kurangi',
                        onPressed: item.quantity > 0
                            ? () {
                                final double next =
                                    (item.quantity - 1.0).clamp(0.0, double.infinity);
                                onQuantityChanged(next);
                              }
                            : null,
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 28),
                        alignment: Alignment.center,
                        child: Text(
                          _formatQuantity(item.quantity),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Tambah',
                        onPressed: () {
                          onQuantityChanged(item.quantity + 1.0);
                        },
                      ),
                    ],
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
