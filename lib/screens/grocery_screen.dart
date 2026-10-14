// Owner: Gilbert | FR: FR-14, FR-15, FR-16, FR-17

import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/models/grocery_item.dart';
import 'package:budget_bites/screens/pantry_screen.dart';
import 'package:budget_bites/widgets/grocery_item_tile.dart';
import 'package:flutter/material.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  late List<GroceryItem> _groceryItems;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _groceryItems = List<GroceryItem>.from(mockGroceryItems);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  int get _checkedCount => _groceryItems.where((item) => item.isChecked).length;

  int get _totalPrice => _groceryItems.fold(0, (sum, item) => sum + item.price);

  void _addItem() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _groceryItems.add(
        GroceryItem(
          id: 'g_${DateTime.now().millisecondsSinceEpoch}',
          name: text,
          quantity: 1,
          unit: 'pcs',
          price: 0,
          isChecked: false,
        ),
      );
    });
    _textController.clear();
  }

  void _toggleItem(int index) {
    setState(() {
      final item = _groceryItems[index];
      _groceryItems[index] = item.copyWith(isChecked: !item.isChecked);
    });
  }

  void _deleteItem(int index) {
    final removedItem = _groceryItems[index];
    final removedIndex = index;

    setState(() {
      _groceryItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem.name} dihapus'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () {
            setState(() {
              _groceryItems.insert(
                removedIndex.clamp(0, _groceryItems.length),
                removedItem,
              );
            });
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _moveToPantry() {
    final count = _checkedCount;
    if (count == 0) return;

    setState(() {
      _groceryItems.removeWhere((item) => item.isChecked);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count item berhasil dipindahkan ke Pantry'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalItems = _groceryItems.length;
    final checkedCount = _checkedCount;
    final totalPrice = _totalPrice;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricColumn(
                    context,
                    label: 'Total Item',
                    value: '$totalItems',
                    icon: Icons.format_list_bulleted,
                  ),
                ),
                Container(
                  height: 36,
                  width: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
                Expanded(
                  child: _buildMetricColumn(
                    context,
                    label: 'Sudah Dibeli',
                    value: '$checkedCount / $totalItems',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                Container(
                  height: 36,
                  width: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
                Expanded(
                  child: _buildMetricColumn(
                    context,
                    label: 'Total Estimasi',
                    value: formatRupiah(totalPrice),
                    icon: Icons.payments_outlined,
                  ),
                ),
              ],
            ),
            if (totalItems > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: checkedCount / totalItems,
                  minHeight: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _textController,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _addItem(),
        decoration: InputDecoration(
          hintText: 'Tambah item baru...',
          prefixIcon: const Icon(Icons.add_shopping_cart_outlined),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add_circle),
            color: colorScheme.primary,
            onPressed: _addItem,
            tooltip: 'Tambah',
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
                'Tambahkan bahan makanan yang ingin Anda beli menggunakan kolom di atas',
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
    final checkedCount = _checkedCount;

    return Column(
      children: [
        _buildSummaryCard(context),
        _buildInputRow(context),
        Expanded(
          child: _groceryItems.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  itemCount: _groceryItems.length,
                  padding: const EdgeInsets.only(bottom: 8),
                  itemBuilder: (context, index) {
                    final item = _groceryItems[index];
                    return GroceryItemTile(
                      key: ValueKey(item.id),
                      item: item,
                      onToggle: () => _toggleItem(index),
                      onDismissed: () => _deleteItem(index),
                    );
                  },
                ),
        ),
        if (checkedCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _moveToPantry,
                icon: const Icon(Icons.kitchen_outlined),
                label: Text('Pindahkan $checkedCount item ke Pantry'),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Belanja & Pantry'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Belanja'),
              Tab(text: 'Pantry'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBelanjaTab(context),
            const PantryScreen(),
          ],
        ),
      ),
    );
  }
}
