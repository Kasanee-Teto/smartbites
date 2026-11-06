// Owner: Gilbert | FR: FR-18, FR-19, FR-20, FR-21
// Design: stitch_smartbites_meal_budget_planner/smartbites_belanja_pantry/code.html

import 'package:budget_bites/models/pantry_item.dart';
import 'package:budget_bites/utils/app_colors.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/widgets/pantry_item_tile.dart';
import 'package:flutter/material.dart';

String _formatQty(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toInt().toString();
  }
  return quantity.toString();
}

/// Pantry inventory with grouped categories, critical stock alert banner,
/// expiry alerts, and quantity stepper adjustments (FR-18..FR-21).
///
/// State lives in MainNavigation (see docs/integration_contract.md).
/// Embedded inside GroceryScreen's TabBarView (no separate Scaffold or AppBar).
class PantryScreen extends StatelessWidget {
  const PantryScreen({
    super.key,
    this.items = const [],
    this.onAddItem,
    this.onUpdateItem,
    this.onDeleteItem,
  });
  final List<PantryItem> items;
  final ValueChanged<PantryItem>? onAddItem;
  final ValueChanged<PantryItem>? onUpdateItem;
  final ValueChanged<String>? onDeleteItem;

  List<PantryItem> get _items => items;

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalItems = _items.length;
    final lowStockCount = _items
        .where((item) => item.quantity <= item.minQuantity)
        .length;
    final expiredCount = _items
        .where(
          (item) => getExpiryStatus(item.expiryDate) == ExpiryStatus.expired,
        )
        .length;

    return Card(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.spaceMd,
        12,
        AppConstants.spaceMd,
        8,
      ),
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                context,
                label: 'Total Bahan',
                value: '$totalItems',
                color: colorScheme.primary,
                icon: Icons.inventory_2_outlined,
              ),
            ),
            Container(
              height: 36,
              width: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            Expanded(
              child: _buildSummaryItem(
                context,
                label: 'Stok Menipis',
                value: '$lowStockCount',
                color: AppColors.harvestAmber,
                icon: Icons.warning_amber_rounded,
              ),
            ),
            Container(
              height: 36,
              width: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            Expanded(
              child: _buildSummaryItem(
                context,
                label: 'Kedaluwarsa',
                value: '$expiredCount',
                color: colorScheme.error,
                icon: Icons.error_outline_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Critical Stock Alert banner modeled after lines 248-282 of
  /// `smartbites_belanja_pantry/code.html` (FR-19).
  Widget _buildCriticalStockBanner(
    BuildContext context,
    List<PantryItem> lowStockItems,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: 6,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: colorScheme.error,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Stok Menipis & Kritis',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${lowStockItems.length} Bahan Wajib Isi',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in lowStockItems.take(2))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusDefault,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.name} (${item.category})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sisa ${_formatQty(item.quantity)} / min ${_formatQty(item.minQuantity)} ${item.unit}',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusFull,
                      ),
                      child: LinearProgressIndicator(
                        value: item.minQuantity > 0
                            ? (item.quantity / (item.minQuantity * 2)).clamp(
                                0.08,
                                1.0,
                              )
                            : 0.2,
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(
    BuildContext context,
    String category,
    int count,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceMd,
        14,
        AppConstants.spaceMd,
        4,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Text(
              '$count item',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.kitchen_outlined,
                size: 72,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Pantry kosong',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Belum ada bahan makanan yang tersimpan di pantry Anda.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return _buildEmptyState(context);
    }

    final lowStockItems = _items
        .where((item) => item.quantity <= item.minQuantity)
        .toList();

    // Group items by category (FR-18)
    final groupedItems = <String, List<PantryItem>>{};
    for (final item in _items) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    // Sort categories alphabetically
    final sortedCategories = groupedItems.keys.toList()..sort();

    // Single flat ListView with mixed header + item children
    final listChildren = <Widget>[
      _buildSummaryCard(context),
      if (lowStockItems.isNotEmpty)
        _buildCriticalStockBanner(context, lowStockItems),
    ];

    for (final category in sortedCategories) {
      final categoryItems = groupedItems[category]!;
      listChildren.add(
        _buildCategoryHeader(context, category, categoryItems.length),
      );
      for (final item in categoryItems) {
        listChildren.add(
          PantryItemTile(
            key: ValueKey(item.id),
            item: item,
            onQuantityChanged: (newQuantity) {
              onUpdateItem?.call(item.copyWith(quantity: newQuantity));
            },
          ),
        );
      }
    }

    listChildren.add(const SizedBox(height: 88));

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: listChildren,
    );
  }
}
