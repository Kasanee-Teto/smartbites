// Owner: Edbert | FR: FR-24, FR-25, FR-33, FR-34
// Design: stitch_smartbites_meal_budget_planner/smartbites_air_food_waste/code.html

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/pantry_item.dart';
import 'package:budget_bites/models/waste_record.dart';
import 'package:budget_bites/utils/app_colors.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/sdg_badge.dart';
import 'package:budget_bites/widgets/status_badge.dart';
import 'package:budget_bites/widgets/waste_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Saran item untuk chip. Harga penuh bernilai null bila tidak diketahui.
class _Suggestion {
  final String name;
  final int? fullPrice;

  const _Suggestion(this.name, this.fullPrice);
}

class FoodWasteScreen extends StatefulWidget {
  static const List<String> reasonOptions = [
    'Basi / Busuk',
    'Beli Kebanyakan',
    'Sisa Piring',
    'Lupa Diolah',
  ];

  final List<WasteRecord> records;
  final ValueChanged<WasteRecord>? onAddRecord;
  final ValueChanged<String>? onDeleteRecord;

  /// Sumber chip: item Pantry (harga belum diketahui) dan menu terakhir.
  final List<PantryItem> pantryItems;
  final List<Meal> recentMeals;

  /// Tombol "Tidak ada yang terbuang hari ini" (FR-34).
  final bool noWasteMarked;
  final VoidCallback? onMarkNoWaste;

  /// Tanggal acuan untuk total bulan ini; bawaannya hari ini (memudahkan test).
  final DateTime? now;

  const FoodWasteScreen({
    super.key,
    this.records = const [],
    this.onAddRecord,
    this.onDeleteRecord,
    this.pantryItems = const [],
    this.recentMeals = const [],
    this.noWasteMarked = false,
    this.onMarkNoWaste,
    this.now,
  });

  @override
  State<FoodWasteScreen> createState() => _FoodWasteScreenState();
}

class _FoodWasteScreenState extends State<FoodWasteScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _portion = WastePortions.setengah;
  String _reason = '';
  int? _fullPrice;
  String? _nameError;

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  List<_Suggestion> _suggestions() {
    final seen = <String>{};
    final result = <_Suggestion>[];
    for (final item in widget.pantryItems) {
      if (seen.add(item.name)) result.add(_Suggestion(item.name, null));
    }
    for (final meal in widget.recentMeals) {
      if (seen.add(meal.name)) result.add(_Suggestion(meal.name, meal.price));
    }
    return result.take(8).toList();
  }

  void _selectSuggestion(_Suggestion suggestion) {
    setState(() {
      _nameController.text = suggestion.name;
      _nameError = null;
      _fullPrice = suggestion.fullPrice;
      final full = suggestion.fullPrice;
      _priceController.text =
          full == null ? '' : WastePortions.estimateLoss(_portion, full).toString();
    });
  }

  void _selectPortion(String portion) {
    setState(() {
      _portion = portion;
      final full = _fullPrice;
      if (full != null) {
        _priceController.text =
            WastePortions.estimateLoss(portion, full).toString();
      }
    });
  }

  void _resetForm() {
    _nameController.clear();
    _priceController.clear();
    _portion = WastePortions.setengah;
    _reason = '';
    _fullPrice = null;
    _nameError = null;
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Nama item wajib diisi');
      return;
    }

    final record = WasteRecord(
      id: 'wr_${DateTime.now().millisecondsSinceEpoch}',
      itemName: name,
      portion: _portion,
      reason: _reason,
      estimatedLoss: int.tryParse(_priceController.text) ?? 0,
      date: _now,
    );

    widget.onAddRecord?.call(record);
    setState(_resetForm);
  }

  int _monthlyLoss() {
    final now = _now;
    return widget.records
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .fold<int>(0, (sum, r) => sum + r.estimatedLoss);
  }

  List<WasteRecord> _sortedRecords() {
    final list = List<WasteRecord>.from(widget.records);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<Widget> _withGaps(List<Widget> children) {
    return [
      for (int i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(height: AppConstants.spaceMd),
        children[i],
      ],
    ];
  }

  Widget _buildForm(ThemeData theme) {
    final suggestions = _suggestions();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Catat Makanan Terbuang', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppConstants.spaceMd),
            if (suggestions.isNotEmpty) ...[
              Text('Pilih item', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppConstants.spaceSm),
              Wrap(
                spacing: AppConstants.spaceSm,
                runSpacing: AppConstants.spaceSm,
                children: [
                  for (final s in suggestions)
                    ChoiceChip(
                      label: Text(s.name),
                      selected: _nameController.text == s.name,
                      onSelected: (_) => _selectSuggestion(s),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMd),
            ],
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Nama item',
                hintText: 'Contoh: Sawi Putih',
                errorText: _nameError,
              ),
              onChanged: (_) => setState(() {
                _nameError = null;
                _fullPrice = null;
              }),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Text('Porsi', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppConstants.spaceSm),
            Wrap(
              spacing: AppConstants.spaceSm,
              children: [
                for (final p in WastePortions.all)
                  ChoiceChip(
                    label: Text(p),
                    selected: _portion == p,
                    onSelected: (_) => _selectPortion(p),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: const InputDecoration(
                labelText: 'Estimasi kerugian (opsional)',
                prefixText: 'Rp ',
              ),
              // Diubah manual: berhenti menghitung otomatis dari porsi.
              onChanged: (_) => _fullPrice = null,
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Text('Alasan (opsional)', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppConstants.spaceSm),
            Wrap(
              spacing: AppConstants.spaceSm,
              runSpacing: AppConstants.spaceSm,
              children: [
                for (final r in FoodWasteScreen.reasonOptions)
                  ChoiceChip(
                    label: Text(r),
                    selected: _reason == r,
                    onSelected: (selected) {
                      setState(() => _reason = selected ? r : '');
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            FilledButton.icon(
              onPressed: widget.onAddRecord == null ? null : _submit,
              icon: const Icon(Icons.add),
              label: const Text('Catat Makanan Terbuang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWasteCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: theme.colorScheme.primary),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    'Catatan Harian',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (widget.noWasteMarked)
                  const StatusBadge(
                    label: 'Tercatat',
                    icon: Icons.check_circle_outline,
                    type: StatusBadgeType.success,
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),
            FilledButton.tonalIcon(
              onPressed: widget.noWasteMarked ? null : widget.onMarkNoWaste,
              icon: const Icon(Icons.check),
              label: const Text('Tidak ada yang terbuang hari ini'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.savings_outlined,
                  color: AppColors.alertTerracotta,
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    'Kerugian Bulan Ini',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              formatRupiah(_monthlyLoss()),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.alertTerracotta,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'Makin sedikit yang terbuang, makin hemat dan makin ramah bumi.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppConstants.spaceSm),
            const SdgBadge.sdg12(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory(ThemeData theme) {
    final sorted = _sortedRecords();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Riwayat Food Waste', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppConstants.spaceSm),
        Card(
          child: sorted.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  child: Column(
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        size: 40.0,
                        color: theme.colorScheme.primary.withAlpha(150),
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      Text(
                        'Belum ada catatan makanan terbuang',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (final record in sorted)
                      WasteItemTile(
                        record: record,
                        onDelete: widget.onDeleteRecord,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            windowSizeFor(constraints.maxWidth) == WindowSize.compact;

        final form = _buildForm(theme);
        final noWaste = _buildNoWasteCard(theme);
        final summary = _buildSummaryCard(theme);
        final history = _buildHistory(theme);

        return SingleChildScrollView(
          // Ruang bawah agar tidak tertutup tombol Catat Cepat.
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
                      children: _withGaps([summary, noWaste, form, history]),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _withGaps([form]),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _withGaps([summary, noWaste, history]),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}