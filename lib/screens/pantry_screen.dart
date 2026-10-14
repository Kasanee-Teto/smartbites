// Owner: Gilbert | FR: FR-18, FR-19, FR-20, FR-21

import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/models/pantry_item.dart';
import 'package:budget_bites/widgets/pantry_item_tile.dart';
import 'package:flutter/material.dart';

/// Screen representing the pantry inventory with grouped categories, stock status,
/// expiry alerts, and quantity stepper adjustments.
///
/// Embedded inside GroceryScreen's TabBarView (no separate Scaffold or AppBar).
class PantryScreen extends StatefulWidget {
  final List<PantryItem>? initialItems;

  const PantryScreen({super.key, this.initialItems});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  late List<PantryItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems != null
        ? List<PantryItem>.from(widget.initialItems!)
        : List<PantryItem>.from(mockPantryItems);
  }

  void _updateItemQuantity(String id, double newQuantity) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
      }
    });
  }

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
    final lowStockCount =
        _items.where((item) => item.quantity <= item.minQuantity).length;
    final expiredCount = _items
        .where((item) => getExpiryStatus(item.expiryDate) == ExpiryStatus.expired)
        .length;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                color: Colors.amber.shade800,
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

  Widget _buildCategoryHeader(
    BuildContext context,
    String category,
    int count,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
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
              borderRadius: BorderRadius.circular(12),
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

    // Group items by category (FR-18)
    final Map<String, List<PantryItem>> groupedItems = {};
    for (final item in _items) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    // Sort categories alphabetically
    final sortedCategories = groupedItems.keys.toList()..sort();

    // Build single flat list with mixed header + item children (NOT nested ListViews)
    final List<Widget> listChildren = [];

    // 1. Summary row at top
    listChildren.add(_buildSummaryCard(context));

    // 2. Grouped category headers and items
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
              _updateItemQuantity(item.id, newQuantity);
            },
          ),
        );
      }
    }

    listChildren.add(const SizedBox(height: 24));

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: listChildren,
    );
  }
}
