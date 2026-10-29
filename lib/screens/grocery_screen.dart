// Owner: Gilbert | FR: FR-14, FR-15, FR-16, FR-17
// Design: stitch_smartbites_meal_budget_planner/smartbites_belanja_pantry/code.html

import 'package:budget_bites/models/grocery_item.dart';
import 'package:budget_bites/screens/pantry_screen.dart';
import 'package:budget_bites/utils/app_colors.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/widgets/grocery_item_tile.dart';
import 'package:flutter/material.dart';

/// Belanja & Pantry tab modeled after `smartbites_belanja_pantry/code.html`.
/// State lives in MainNavigation (see docs/integration_contract.md); this
/// screen renders [items] and reports changes through callbacks.
class GroceryScreen extends StatefulWidget {
  const GroceryScreen({
    super.key,
    this.items = const [],
    this.weeklyBudget = 300000,
    this.onToggleItem,
    this.onAddItem,
    this.onDeleteItem,
    this.onClearChecked,
    this.pantryView,
  });
  final List<GroceryItem> items;
  final int weeklyBudget;
  final ValueChanged<String>? onToggleItem;
  final ValueChanged<GroceryItem>? onAddItem;
  final ValueChanged<String>? onDeleteItem;

  /// Moves all checked items to the Pantry (FR-17).
  final VoidCallback? onClearChecked;

  /// Content of the "Pantry / Stok" tab, built by the parent with its own data.
  final Widget? pantryView;

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final TextEditingController _textController = TextEditingController();
  int _activeTabIndex = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  List<GroceryItem> get _items => widget.items;

  int get _checkedCount => _items.where((item) => item.isChecked).length;

  int get _totalPrice => _items.fold(0, (sum, item) => sum + item.price);

  void _addItem() {
    final text = _textController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (text.isEmpty) return;

    widget.onAddItem?.call(
      GroceryItem(
        id: 'g_${DateTime.now().millisecondsSinceEpoch}',
        name: text,
        quantity: 1,
        unit: 'pcs',
        price: 8500, // Default student budget estimation from HTML spec
      ),
    );
    _textController.clear();
  }

  /// Segmented pill tab bar matching lines 24-35 of `code.html`.
  Widget _buildSegmentedTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceMd,
        8,
        AppConstants.spaceMd,
        6,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSegmentPill(
                context,
                index: 0,
                icon: Icons.receipt_long_outlined,
                label: 'Daftar Belanja',
                badgeCount: _items.length,
              ),
            ),
            Expanded(
              child: _buildSegmentPill(
                context,
                index: 1,
                icon: Icons.kitchen_outlined,
                label: 'Pantry / Stok',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentPill(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    int? badgeCount,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _activeTabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.12)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  '$badgeCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Quick Mini Insight Card for Smart Shopping (lines 37-48 of `code.html`).
  Widget _buildBudgetInsightBanner(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isWithinBudget = _totalPrice <= widget.weeklyBudget;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: 4,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.harvestAmberContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.harvestAmberContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.savings_outlined,
                color: AppColors.harvestAmber,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Sisa Budget Mingguan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusFull,
                          ),
                        ),
                        child: Text(
                          isWithinBudget ? 'Terkendali' : 'Melebihi Budget',
                          style: textTheme.labelSmall?.copyWith(
                            color: isWithinBudget
                                ? AppColors.harvestAmber
                                : colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isWithinBudget
                        ? 'Estimasi belanjaan ini aman dalam sisa '
                              'batas saku kosan!'
                        : 'Total belanja melebihi batas anggaran '
                              'mingguan Anda.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Inline Add Field (FR-15, lines 50-58 of `code.html`).
  Widget _buildInputRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: 6,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.done,
                maxLength: 50,
                onSubmitted: (_) => _addItem(),
                decoration: const InputDecoration(
                  hintText: '+ Ketik bahan baru lalu tekan Enter...',
                  counterText: '',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 34,
              height: 34,
              child: IconButton.filled(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.keyboard_return, size: 18),
                onPressed: _addItem,
                tooltip: 'Tambah item',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section header above the grocery list (lines 61-67 of `code.html`).
  Widget _buildSectionHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceMd,
        4,
        AppConstants.spaceMd,
        2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Target Bahan Pekan Ini ',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: '• Geser kiri hapus',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$_checkedCount dari ${_items.length} selesai',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Summary & CTA Bar (FR-14 & FR-17, lines 339-348 of
  /// `code.html`).
  Widget _buildStickySummaryBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final checkedCount = _checkedCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceMd,
        10,
        AppConstants.spaceMd,
        10,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Estimasi Belanja',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatRupiah(_totalPrice),
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FilledButton.icon(
              onPressed: checkedCount > 0 ? widget.onClearChecked : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.move_to_inbox_outlined, size: 18),
              label: Text(
                'Pindahkan $checkedCount item ke Pantry',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada item belanja',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan bahan makanan yang ingin Anda beli '
                'menggunakan kolom di atas',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBelanjaTab(BuildContext context) {
    return Column(
      children: [
        _buildBudgetInsightBanner(context),
        _buildInputRow(context),
        _buildSectionHeader(context),
        Expanded(
          child: _items.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  itemCount: _items.length,
                  padding: const EdgeInsets.only(bottom: 76),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return GroceryItemTile(
                      key: ValueKey(item.id),
                      item: item,
                      onToggle: () => widget.onToggleItem?.call(item.id),
                      onDismissed: widget.onDeleteItem == null
                          ? null
                          : () => widget.onDeleteItem!(item.id),
                    );
                  },
                ),
        ),
        _buildStickySummaryBar(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSegmentedTabBar(context),
        Expanded(
          child: IndexedStack(
            index: _activeTabIndex,
            children: [
              _buildBelanjaTab(context),
              widget.pantryView ?? const PantryScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
