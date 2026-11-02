// Owner: Jessica, Edbert | Draft preferences applied only on Save.

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/meal_preferences.dart';
import 'package:flutter/material.dart';

class MealPreferencesSheet extends StatefulWidget {
  const MealPreferencesSheet({
    required this.allergies,
    required this.preferences,
    required this.onSave,
    super.key,
  });
  final List<String> allergies;
  final MealPreferences preferences;
  final void Function(List<String> allergies, MealPreferences preferences)
  onSave;

  @override
  State<MealPreferencesSheet> createState() => _MealPreferencesSheetState();
}

class _MealPreferencesSheetState extends State<MealPreferencesSheet> {
  final _form = GlobalKey<FormState>();
  late final Set<String> _allergies = widget.allergies.toSet();
  late MealDiet? _diet = widget.preferences.diet;
  late final _price = TextEditingController(
    text: widget.preferences.maxPrice?.toString() ?? '',
  );
  late final _minutes = TextEditingController(
    text: widget.preferences.maxCookMinutes?.toString() ?? '',
  );

  @override
  void dispose() {
    _price.dispose();
    _minutes.dispose();
    super.dispose();
  }

  String? _validate(String? text, int maximum) {
    if (text == null || text.trim().isEmpty) return null;
    final value = int.tryParse(text.trim());
    if (value == null || value < 0 || value > maximum) {
      return 'Isi angka bulat 0 sampai $maximum, tanpa titik atau koma';
    }
    return null;
  }

  static const _foodSymbols = <String, String>{
    'Susu': '🥛',
    'Telur': '🥚',
    'Kacang': '🥜',
    'Kedelai': '🫘',
    'Gandum': '🌾',
    'Ikan': '🐟',
    'Udang': '🦐',
    'Kepiting': '🦀',
    'Kerang': '🦪',
    'Moluska': '🦑',
    'Santan': '🥥',
    'Bawang': '🧅',
    'Nanas': '🍍',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = {...mealAllergenOptions, ...widget.allergies};
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Preferensi makan',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Tutup tanpa menyimpan',
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Alergi & bahan yang dihindari',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih semua bahan yang ingin kamu hindari',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 8.0;
                    final scale =
                        MediaQuery.textScalerOf(context).scale(14) / 14;
                    final minimumWidth = 100.0 * scale.clamp(1.0, 2.0);
                    final columns =
                        ((constraints.maxWidth + spacing) /
                                (minimumWidth + spacing))
                            .floor()
                            .clamp(1, 4);
                    final width =
                        (constraints.maxWidth - (columns - 1) * spacing) /
                        columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final label in options)
                          SizedBox(
                            width: width,
                            child: _IngredientTile(
                              label: label,
                              symbol: _foodSymbols[label],
                              selected: _allergies.contains(label),
                              onTap: () => setState(() {
                                if (!_allergies.add(label)) {
                                  _allergies.remove(label);
                                }
                              }),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text('Pilihan makanan', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Pilih satu pola makan yang paling sesuai',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final diet in <MealDiet?>[null, ...MealDiet.values])
                      _DietChip(
                        label: diet?.label ?? 'Tanpa preferensi',
                        icon: diet == null
                            ? Icons.restaurant_menu_rounded
                            : diet.label.toLowerCase() == 'vegan'
                            ? Icons.eco_rounded
                            : Icons.spa_rounded,
                        selected: _diet == diet,
                        onSelected: (_) => setState(() => _diet = diet),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Anggaran & waktu', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Anggaran maksimal per porsi',
                    labelStyle: TextStyle(fontSize: 14),
                    prefixText: 'Rp ',
                    helperText: 'Opsional (Kosongkan untuk tanpa batas)',
                    errorMaxLines: 3,
                    helperMaxLines: 2,
                  ),
                  validator: (text) => _validate(text, 10000000),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _minutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Waktu masak maksimal',
                    labelStyle: TextStyle(fontSize: 14),
                    suffixText: 'menit',
                    helperText: 'Opsional (Menu beli dihitung 0 menit masak)',
                    errorMaxLines: 3,
                    helperMaxLines: 2,
                  ),
                  validator: (text) => _validate(text, 1440),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    if (!_form.currentState!.validate()) return;
                    widget.onSave(
                      _allergies.toList(),
                      MealPreferences(
                        diet: _diet,
                        maxPrice: int.tryParse(_price.text.trim()),
                        maxCookMinutes: int.tryParse(_minutes.text.trim()),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Simpan preferensi'),
                ),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: () => setState(() {
                    _allergies.clear();
                    _diet = null;
                    _price.clear();
                    _minutes.clear();
                  }),
                  child: const Text('Atur ulang pilihan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({
    required this.label,
    required this.symbol,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? symbol;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(18);
    return Semantics(
      label: label,
      checked: selected,
      enabled: true,
      child: Material(
        color: selected
            ? colors.primaryContainer
            : colors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 1.8 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          excludeFromSemantics: true,
          borderRadius: radius,
          child: Semantics(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 112),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ExcludeSemantics(
                            child: Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? colors.surface.withAlpha(190)
                                    : colors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: label == 'Wijen'
                                  ? CustomPaint(
                                      size: const Size(30, 30),
                                      painter: _SesamePainter(
                                        colors.onSurfaceVariant,
                                      ),
                                    )
                                  : symbol != null
                                  ? Text(
                                      symbol!,
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(fontSize: 28),
                                    )
                                  : Icon(
                                      Icons.no_food_outlined,
                                      color: colors.onSurfaceVariant,
                                      size: 26,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ExcludeSemantics(
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: 14,
                                height: 1.25,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: ExcludeSemantics(
                      child: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 17,
                        color: selected ? Colors.white : colors.onSurface,
                      ),
                    ),
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

class _DietChip extends StatelessWidget {
  const _DietChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = selected ? Colors.white : colors.onSurface;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 20, color: foreground),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      backgroundColor: colors.surfaceContainerLowest,
      selectedColor: colors.primaryContainer,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      side: BorderSide(
        color: selected ? colors.primary : colors.outlineVariant,
        width: selected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _SesamePainter extends CustomPainter {
  const _SesamePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const seeds = <(double, double, double)>[
      (0.30, 0.23, -0.5),
      (0.65, 0.20, 0.7),
      (0.47, 0.48, 0.3),
      (0.20, 0.60, -0.6),
      (0.76, 0.53, -0.4),
      (0.40, 0.80, 0.6),
      (0.70, 0.80, 0.3),
    ];
    for (final seed in seeds) {
      canvas
        ..save()
        ..translate(seed.$1 * size.width, seed.$2 * size.height)
        ..rotate(seed.$3)
        ..drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: size.width * 0.13,
            height: size.height * 0.24,
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SesamePainter oldDelegate) =>
      oldDelegate.color != color;
}
