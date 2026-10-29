// Owner: Gilbert | FR: FR-18, FR-19, FR-20, FR-21
// Design: stitch_smartbites_meal_budget_planner/smartbites_belanja_pantry/code.html

import 'package:budget_bites/models/pantry_item.dart';
import 'package:budget_bites/utils/app_colors.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:flutter/material.dart';

/// Enum representing the freshness status of a pantry item based on expiry
/// date.
enum ExpiryStatus { safe, expiringSoon, expired }

/// Indonesian month abbreviations for manual date formatting without the intl
/// package.
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

/// Formats a [DateTime] into Indonesian date format 'dd MMM yyyy'
/// (e.g., '14 Okt 2026').
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

/// Maps a pantry category name to a representative Material icon.
IconData _iconForCategory(String category) {
  return switch (category.toLowerCase()) {
    'protein' => Icons.egg_outlined,
    'sayuran' => Icons.eco_outlined,
    'bumbu' => Icons.spa_outlined,
    'pokok' => Icons.rice_bowl_outlined,
    'minuman' => Icons.local_drink_outlined,
    _ => Icons.kitchen_outlined,
  };
}

/// A reusable widget representing a single pantry item row matching the
/// Stitch HTML design (`smartbites_belanja_pantry/code.html`).
class PantryItemTile extends StatelessWidget {
  const PantryItemTile({
    required this.item,
    required this.onQuantityChanged,
    super.key,
  });
  final PantryItem item;
  final ValueChanged<double> onQuantityChanged;

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
      case ExpiryStatus.expiringSoon:
        backgroundColor = isDark
            ? AppColors.harvestAmber.withValues(alpha: 0.35)
            : AppColors.harvestAmberContainer;
        textColor = isDark
            ? AppColors.harvestAmberContainer
            : AppColors.harvestAmber;
        label = 'Segera habis';
      case ExpiryStatus.expired:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        label = 'Kedaluwarsa';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final status = getExpiryStatus(item.expiryDate);
    final maxQuantity = item.minQuantity > 0 ? item.minQuantity * 2 : 1.0;
    final progressValue = (item.quantity / maxQuantity).clamp(0.0, 1.0);
    final isLowStock = item.quantity <= item.minQuantity;
    const warningColor = AppColors.alertTerracotta;

    final (Color iconBoxBg, Color iconBoxFg) = switch (status) {
      ExpiryStatus.expired => (
        colorScheme.errorContainer.withValues(alpha: 0.6),
        colorScheme.error,
      ),
      ExpiryStatus.expiringSoon => (
        AppColors.harvestAmberContainer.withValues(alpha: 0.6),
        AppColors.harvestAmber,
      ),
      ExpiryStatus.safe => (
        colorScheme.primaryContainer.withValues(alpha: 0.4),
        colorScheme.primary,
      ),
    };

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: 5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Leading category icon box (40x40 rounded-xl from HTML)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBoxBg,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Icon(
                    _iconForCategory(item.category),
                    color: iconBoxFg,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Center item details + inline expiry badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            item.name,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          _buildExpiryBadge(context, item.expiryDate),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        status == ExpiryStatus.expired
                            ? 'Kedaluwarsa '
                                  '${formatExpiryDate(item.expiryDate)} • '
                                  'Buang via Waste'
                            : 'Exp: ${formatExpiryDate(item.expiryDate)} • '
                                  '${item.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: status == ExpiryStatus.expired
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                          fontWeight: status == ExpiryStatus.expired
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Right: Circular Stepper Pill (FR-21 from HTML)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerLowest,
                          foregroundColor: colorScheme.onSurface,
                        ),
                        tooltip: 'Kurangi',
                        onPressed: item.quantity > 0
                            ? () {
                                final next = (item.quantity - 1.0).clamp(
                                  0.0,
                                  double.infinity,
                                );
                                onQuantityChanged(next);
                              }
                            : null,
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 28),
                        alignment: Alignment.center,
                        child: Text(
                          _formatQuantity(item.quantity),
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
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
            const SizedBox(height: 10),
            // Stock gauge & low-stock label (FR-19)
            Row(
              children: [
                Text(
                  '${_formatQuantity(item.quantity)} ${item.unit}',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isLowStock
                        ? warningColor
                        : colorScheme.onSurfaceVariant,
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
                      color: warningColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSm,
                      ),
                    ),
                    child: Text(
                      'Stok menipis',
                      style: textTheme.labelSmall?.copyWith(
                        color: warningColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull,
                    ),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isLowStock ? warningColor : colorScheme.primary,
                      ),
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
