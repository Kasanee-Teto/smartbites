// Owner: Jessica | Search and compare local meal options.

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/meal_preferences.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/widgets/list_tile_spacing.dart';
import 'package:budget_bites/widgets/meal_card.dart';
import 'package:budget_bites/widgets/option_icon.dart';
import 'package:flutter/material.dart';

class MealCatalog extends StatefulWidget {
  const MealCatalog({
    required this.meals,
    required this.allergies,
    required this.focus,
    required this.onSelect,
    required this.onDetail,
    this.preferences = const MealPreferences(),
    super.key,
  });
  final List<Meal> meals;
  final List<String> allergies;
  final NutritionFocus focus;
  final MealPreferences preferences;
  final ValueChanged<Meal> onSelect;
  final ValueChanged<Meal> onDetail;

  @override
  State<MealCatalog> createState() => _MealCatalogState();
}

class _MealCatalogState extends State<MealCatalog> {
  String _query = '';
  MealSource? _source;
  String? _category;
  String? _hoveredSource;
  int _visible = 12;
  bool _showFilters = false;
  final _maxCholesterol = TextEditingController();

  @override
  void dispose() {
    _maxCholesterol.dispose();
    super.dispose();
  }

  double? _number(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    return parsed != null && parsed.isFinite && parsed >= 0 ? parsed : null;
  }

  String? _error(TextEditingController controller) =>
      controller.text.trim().isNotEmpty && _number(controller.text) == null
      ? 'Masukkan angka nol atau lebih'
      : null;

  @override
  Widget build(BuildContext context) {
    final maxCholesterol = _number(_maxCholesterol.text);
    final results = widget.meals.where((meal) {
      if (_source != null && meal.source != _source) return false;
      if (_category != null && meal.category != _category) return false;
      if (matchesAllergy(meal, widget.allergies)) {
        return false;
      }
      if (!meal.name.toLowerCase().contains(_query.toLowerCase())) return false;
      if (!widget.preferences.matches(meal)) return false;
      if (maxCholesterol != null) {
        final cholesterol = meal.nutrition.cholesterolMilligrams;
        if (cholesterol == null || cholesterol > maxCholesterol) return false;
      }
      return true;
    }).toList();
    if (widget.focus != NutritionFocus.general) {
      results.sort((a, b) {
        final nutrient = widget.focus == NutritionFocus.heart
            ? Nutrient.sodium
            : Nutrient.saturatedFat;
        return nutrient.amount(a)!.compareTo(nutrient.amount(b)!);
      });
    }

    Widget sourceOption(MealSource? source) {
      final colors = Theme.of(context).colorScheme;
      final token = source?.name ?? 'all';
      final selected = _source == source;
      final active = selected || _hoveredSource == token;

      final label = switch (source) {
        null => 'Semua\nmenu',
        MealSource.cook => 'Masak\nsendiri',
        MealSource.buy => 'Beli siap\nmakan',
      };

      final icon = switch (source) {
        null => Icons.restaurant_menu_rounded,
        MealSource.cook => Icons.soup_kitchen_outlined,
        MealSource.buy => Icons.storefront_outlined,
      };

      return Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: active ? colors.primary : colors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: active ? colors.primary : colors.outlineVariant,
              width: 1.5,
            ),
          ),
          child: InkWell(
            hoverColor: Colors.transparent,
            onHover: (hovered) {
              setState(() {
                _hoveredSource = hovered ? token : null;
              });
            },
            onTap: () {
              setState(() {
                _source = source;
                _visible = 12;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Icon(
                            icon,
                            size: 28,
                            color: active
                                ? Colors.white
                                : colors.onSurfaceVariant,
                          ),
                        ),
                        if (selected)
                          const Positioned(
                            right: 0,
                            top: 0,
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: (text) => setState(() {
            _query = text;
            _visible = 12;
          }),
          decoration: const InputDecoration(
            labelText: 'Cari menu Indonesia',
            labelStyle: TextStyle(fontSize: 14),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: sourceOption(null)),
              const SizedBox(width: 10),
              Expanded(child: sourceOption(MealSource.cook)),
              const SizedBox(width: 10),
              Expanded(child: sourceOption(MealSource.buy)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 5),
            ListTileSpacing(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                minTileHeight: 48,
                dense: true,
                title: Text(
                  'Saring pilihan',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                leading: const OptionIcon(
                  icon: Icons.tune,
                  color: Colors.blue,
                  size: 28,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minLeadingWidth: 28,
                trailing: Icon(
                  _showFilters ? Icons.expand_less : Icons.expand_more,
                ),
                onTap: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            if (_showFilters) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in <String?>[
                    null,
                    ...widget.meals.map((meal) => meal.category).toSet(),
                  ])
                    ChoiceChip(
                      selected: _category == category,
                      showCheckmark: false,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      surfaceTintColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: _category == category
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                      avatar: Icon(
                        switch (category) {
                          null => Icons.schedule_rounded,
                          'Sarapan' => Icons.wb_sunny_outlined,
                          'Makan Siang' => Icons.lunch_dining_outlined,
                          'Makan Malam' => Icons.nightlight_round,
                          _ => Icons.cookie_outlined,
                        },
                        size: 20,
                        color: _category == category
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(category ?? 'Semua waktu'),
                      labelStyle: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _category == category
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                      onSelected: (_) {
                        setState(() {
                          _category = category;
                          _visible = 12;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _maxCholesterol,
                style: Theme.of(context).textTheme.bodyMedium,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  setState(() {
                    _visible = 12;
                  });
                },
                decoration: InputDecoration(
                  isDense: true,
                  constraints: const BoxConstraints(minHeight: 48),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorMaxLines: 2,
                  labelText: 'Kolesterol maksimal per porsi',
                  labelStyle: const TextStyle(fontSize: 14),
                  errorText: _error(_maxCholesterol),
                  suffixText: 'mg',
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
        if (widget.focus != NutritionFocus.general)
          Text(
            widget.focus == NutritionFocus.heart
                ? 'Diurutkan berdasarkan natrium terendah'
                : 'Diurutkan berdasarkan lemak jenuh terendah',
          ),
        const SizedBox(height: 8),
        if (results.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Belum ada menu sesuai pencarian (Coba ubah preferensi atau filter) '
              'Catatan: Menu tanpa tag diet dikecualikan jika diet dipilih ',
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth >= 680 &&
                    MediaQuery.textScalerOf(context).scale(14) <= 18
                ? 2
                : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final meal in results.take(_visible))
                  SizedBox(
                    width: width,
                    child: MealCard(
                      key: ValueKey('catalog_${meal.id}'),
                      meal: meal,
                      hasAllergy: matchesAllergy(meal, widget.allergies),
                      onSelect: () => widget.onSelect(meal),
                      onTap: () => widget.onDetail(meal),
                    ),
                  ),
              ],
            );
          },
        ),
        if (results.length > _visible) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => setState(() => _visible += 12),
            child: const Text('Tampilkan lebih banyak'),
          ),
        ],
      ],
    );
  }
}
