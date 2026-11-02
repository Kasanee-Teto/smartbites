// Owner: Jessica | Calendar, food diary, and local nutrition tracker.

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/meal_preferences.dart';
import 'package:budget_bites/models/planned_meal.dart';
import 'package:budget_bites/screens/meal_detail_screen.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/meal_card.dart';
import 'package:budget_bites/widgets/meal_catalog.dart';
import 'package:budget_bites/widgets/meal_editor_sheet.dart';
import 'package:budget_bites/widgets/meal_preferences_sheet.dart';
import 'package:budget_bites/widgets/nutrition_goals_sheet.dart';
import 'package:budget_bites/widgets/nutrition_summary.dart';
import 'package:budget_bites/widgets/option_icon.dart';
import 'package:budget_bites/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({
    required this.entries,
    required this.meals,
    required this.goals,
    required this.focus,
    required this.onSave,
    required this.onDelete,
    required this.onGoalsChanged,
    required this.onFocusChanged,
    required this.onAddToGrocery,
    this.allergies = const [],
    this.preferences = const MealPreferences(),
    this.onPreferencesChanged,
    this.weeklyBudget = 300000,
    this.initialDate,
    super.key,
  });
  final List<PlannedMeal> entries;
  final List<Meal> meals;
  final List<String> allergies;
  final MealPreferences preferences;
  final void Function(List<String>, MealPreferences)? onPreferencesChanged;
  final Map<Nutrient, double> goals;
  final NutritionFocus focus;
  final int weeklyBudget;
  final DateTime? initialDate;
  final ValueChanged<PlannedMeal> onSave;
  final ValueChanged<String> onDelete;
  final ValueChanged<Map<Nutrient, double>> onGoalsChanged;
  final ValueChanged<NutritionFocus> onFocusChanged;
  final void Function(Meal meal, double servings) onAddToGrocery;

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  late DateTime _date;
  int _section = 0;
  bool _week = false;
  bool _onlyEaten = true;

  Map<String, Meal> get _catalog => {for (final m in widget.meals) m.id: m};
  List<PlannedMeal> _entriesForDay(DateTime date) => sortPlannedMeals(
    mealsOnDay(widget.entries, date),
    _catalog,
    widget.focus,
  );
  List<PlannedMeal> get _dayEntries => _entriesForDay(_date);

  void _replaceAllergenicMeals() {
    final catalog = _catalog;
    final safeMeals = widget.meals
        .where(
          (meal) =>
              !matchesAllergy(meal, widget.allergies) &&
              widget.preferences.matches(meal),
        )
        .toList();
    if (safeMeals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada menu yang sesuai dengan profil alergi'),
        ),
      );
      return;
    }
    final entries = mealsOnDay(widget.entries, _date);
    var replaced = 0;
    for (final entry in entries) {
      final meal = catalog[entry.mealId];

      if (entry.isEaten ||
          meal == null ||
          !matchesAllergy(meal, widget.allergies)) {
        continue;
      }
      final replacement = safeMeals[replaced % safeMeals.length];
      widget.onSave(
        PlannedMeal(
          id: entry.id,
          mealId: replacement.id,
          scheduledAt: entry.scheduledAt,
          servings: entry.servings,
          isEaten: entry.isEaten,
        ),
      );
      replaced++;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          replaced == 0
              ? 'Tidak ada menu beralergen yang perlu diganti.'
              : '$replaced menu diganti sesuai profil alergi',
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _date = calendarDay(widget.initialDate ?? DateTime.now());
  }

  Future<void> _edit({
    PlannedMeal? entry,
    Meal? meal,
    double servings = 1,
    bool eaten = false,
    int? hour,
  }) {
    if (widget.meals.isEmpty) return Future<void>.value();
    return showModalBottomSheet<PlannedMeal>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => MealEditorSheet(
        meals: widget.meals,
        date: _date,
        entry: entry,
        initialMeal: meal,
        initialServings: servings,
        initialEaten: eaten,
        initialTime: hour == null ? null : TimeOfDay(hour: hour, minute: 0),
        allergies: widget.allergies,
      ),
    ).then((result) {
      if (result != null && mounted) {
        widget.onSave(result);
        setState(() {
          _date = calendarDay(result.scheduledAt);
          _section = 0;
        });
      }
    });
  }

  Future<void> _pickDate() {
    return showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Pilih tanggal rencana',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    ).then((result) {
      if (result != null && mounted) setState(() => _date = result);
    });
  }

  Future<void> _goals() {
    return showModalBottomSheet<Map<Nutrient, double>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => NutritionGoalsSheet(goals: widget.goals),
    ).then((result) {
      if (result != null && mounted) widget.onGoalsChanged(result);
    });
  }

  void _detail(Meal meal) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (detailContext) => MealDetailScreen(
          meal: meal,
          userAllergies: widget.allergies,
          onAddToGrocery: widget.onAddToGrocery,
          onPlan: (selected, servings) =>
              _planFromDetail(detailContext, selected, servings),
        ),
      ),
    );
  }

  Future<void> _planFromDetail(
    BuildContext detailContext,
    Meal meal,
    double servings,
  ) {
    Navigator.of(detailContext).pop();
    return _edit(meal: meal, servings: servings);
  }

  Future<void> _addAt(DateTime date, int hour) {
    setState(() => _date = date);
    return _edit(hour: hour);
  }

  void _toggle(PlannedMeal entry, bool eaten) {
    if (eaten &&
        calendarDay(entry.scheduledAt).isAfter(calendarDay(DateTime.now()))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal mendatang belum bisa dicatat dimakan'),
        ),
      );
      return;
    }
    widget.onSave(entry.copyWith(isEaten: eaten));
  }

  Widget _entry(PlannedMeal entry) {
    final meal = _catalog[entry.mealId];
    if (meal == null) {
      return ListTile(
        title: const Text('Menu tidak tersedia'),
        trailing: IconButton(
          onPressed: () => widget.onDelete(entry.id),
          tooltip: 'Hapus menu',
          icon: const Icon(Icons.delete_outline),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MealCard(
        key: ValueKey('plan_${entry.id}'),
        meal: meal,
        servings: entry.servings,
        time: mealTimeLabel(entry.scheduledAt),
        isEaten: entry.isEaten,
        hasAllergy: matchesAllergy(meal, widget.allergies),
        onTap: () => _detail(meal),
        onEdit: () => _edit(entry: entry),
        onDelete: () => widget.onDelete(entry.id),
        onEatenChanged: (value) => _toggle(entry, value),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    final monday = mondayOf(_date);
    final weekEntries = widget.entries.where(
      (e) =>
          !e.scheduledAt.isBefore(monday) &&
          e.scheduledAt.isBefore(calendarDay(monday, 7)),
    );
    final cost = plannedCost(weekEntries, _catalog);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Menu & Gizi', style: theme.textTheme.titleLarge),
              ),
              Icon(Icons.restaurant_menu, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Text('${weekEntries.length} menu minggu ini'),
              Text(
                formatRupiah(cost),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: widget.weeklyBudget > 0
                ? (cost / widget.weeklyBudget).clamp(0.0, 1.0)
                : 0,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
            color: cost > widget.weeklyBudget
                ? theme.colorScheme.secondary
                : null,
          ),
          const SizedBox(height: 5),
          Text(
            'Anggaran ${formatRupiah(widget.weeklyBudget)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _preferences() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => MealPreferencesSheet(
      allergies: widget.allergies,
      preferences: widget.preferences,
      onSave: widget.onPreferencesChanged!,
    ),
  );

  Widget _preferencesButton() => OutlinedButton.icon(
    onPressed: widget.onPreferencesChanged == null ? null : _preferences,
    icon: const Icon(Icons.tune, size: 18),
    label: const Text('Preferensi makan'),
  );

  Future<void> _focusPicker() {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fokus perbandingan gizi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final focus in NutritionFocus.values)
                ListTile(
                  leading: OptionIcon(
                    icon: switch (focus) {
                      NutritionFocus.general => Icons.restaurant_menu,
                      NutritionFocus.cholesterol => Icons.water_drop_outlined,
                      NutritionFocus.heart => Icons.favorite_rounded,
                    },
                    color: focus == NutritionFocus.heart
                        ? Colors.red.shade700
                        : focus == NutritionFocus.cholesterol
                        ? Colors.orange.shade800
                        : Colors.green.shade700,
                  ),
                  selected: focus == widget.focus,
                  selectedTileColor: Theme.of(context).colorScheme.primary
                      .withAlpha(18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  trailing: focus == widget.focus
                      ? const Icon(Icons.check_circle)
                      : null,
                  title: Text(focus.label),
                  subtitle: Text(switch (focus) {
                    NutritionFocus.general =>
                      'Jadwal diurutkan menurut waktu makan',
                    NutritionFocus.cholesterol =>
                      'Jadwal diurutkan dari lemak jenuh terendah',
                    NutritionFocus.heart =>
                      'Jadwal diurutkan dari natrium terendah',
                  }),
                  onTap: () {
                    widget.onFocusChanged(focus);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _focusButton() => OutlinedButton.icon(
    onPressed: _focusPicker,
    icon: const Icon(Icons.tune, size: 18),
    label: Text('Fokus: ${widget.focus.label}'),
  );

  Widget _navigation() => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Semantics(
                selected: _section == i,
                child: TextButton(
                  key: ValueKey('meal_section_button_$i'),
                  onPressed: () => setState(() => _section = i),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    backgroundColor: _section == i
                        ? Theme.of(context).colorScheme.surfaceContainerLowest
                        : null,
                    foregroundColor: _section == i
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    ['Rencana', 'Gizi', 'Menu'][i],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _dateBar() => Column(
    children: [
      Row(
        children: [
          IconButton(
            tooltip: 'Periode sebelumnya',
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                setState(() => _date = calendarDay(_date, _week ? -7 : -1)),
          ),
          Expanded(
            child: Tooltip(
              message: 'Pilih tanggal',
              child: TextButton(
                onPressed: _pickDate,
                child: Text(
                  '${_date.day} '
                  '${monthNames[_date.month - 1].substring(0, 3)} ${_date.year}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Periode berikutnya',
            icon: const Icon(Icons.chevron_right),
            onPressed: () =>
                setState(() => _date = calendarDay(_date, _week ? 7 : 1)),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _date = calendarDay(DateTime.now());
              });
            },
            icon: const Icon(Icons.today_outlined),
            label: const Text('Hari ini'),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: _date.weekday == i + 1,
                label:
                    '${shortDays[i]} ${mealDateLabel(calendarDay(mondayOf(_date), i))}',
                child: InkWell(
                  onTap: () =>
                      setState(() => _date = calendarDay(mondayOf(_date), i)),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _date.weekday == i + 1
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          shortDays[i],
                          style: TextStyle(
                            fontSize: 11,
                            color: _date.weekday == i + 1
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${calendarDay(mondayOf(_date), i).day}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _date.weekday == i + 1
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ],
  );

  Widget _calendar() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Hari'),
            showCheckmark: false,
            selected: !_week,
            onSelected: (_) => setState(() => _week = false),
          ),
          ChoiceChip(
            label: const Text('Minggu'),
            showCheckmark: false,
            selected: _week,
            onSelected: (_) => setState(() => _week = true),
          ),
          _focusButton(),
          _preferencesButton(),
          FilledButton.icon(
            onPressed: widget.meals.isEmpty
                ? null
                : () => setState(() => _section = 2),
            icon: const Icon(Icons.add),
            label: const Text('Tambah menu'),
          ),
          OutlinedButton.icon(
            onPressed: widget.allergies.isEmpty
                ? null
                : _replaceAllergenicMeals,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Ganti menu beralergen'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(switch (widget.focus) {
        NutritionFocus.general => 'Urutan: waktu makan',
        NutritionFocus.cholesterol =>
          'Urutan: lemak jenuh terendah sesuai porsi',
        NutritionFocus.heart => 'Urutan: natrium terendah sesuai porsi',
      }, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 12),
      if (_week)
        _weekCalendar()
      else ...[
        if (_dayEntries.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada rencana pada tanggal ini (Pilih menu untuk memulai)',
              ),
            ),
          ),
        for (final entry in _dayEntries) _entry(entry),
      ],
    ],
  );

  String _entryPortion(PlannedMeal entry) =>
      '${nutrientNumber(entry.servings)} porsi'
      '${entry.isEaten ? ' | Dimakan' : ''}';

  int _period(DateTime date) => date.hour < 11
      ? 0
      : date.hour < 15
      ? 1
      : date.hour < 18
      ? 2
      : 3;

  Widget _weekCalendar() {
    final monday = mondayOf(_date);
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = windowSizeFor(constraints.maxWidth) == WindowSize.expanded
            ? constraints.maxWidth
            : 1372.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Table(
              border: TableBorder.all(
                color: colors.outlineVariant.withAlpha(100),
              ),
              columnWidths: const {0: FixedColumnWidth(84)},
              children: [
                TableRow(
                  decoration: BoxDecoration(color: colors.surfaceContainerLow),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Waktu'),
                    ),
                    for (var d = 0; d < 7; d++)
                      TextButton(
                        onPressed: () => setState(() {
                          _date = calendarDay(monday, d);
                          _week = false;
                        }),
                        child: Text(
                          '${shortDays[d]} ${calendarDay(monday, d).day}',
                        ),
                      ),
                  ],
                ),
                for (var period = 0; period < 4; period++)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(['Pagi', 'Siang', 'Sore', 'Malam'][period]),
                      ),
                      for (var d = 0; d < 7; d++)
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 130),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final entry
                                    in _entriesForDay(calendarDay(monday, d))
                                        .where(
                                          (e) =>
                                              _period(e.scheduledAt) == period,
                                        ))
                                  Card(
                                    child: InkWell(
                                      onTap: () => _edit(entry: entry),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              mealTimeLabel(entry.scheduledAt),
                                              style: TextStyle(
                                                color: colors.primary,
                                              ),
                                            ),
                                            Text(
                                              _catalog[entry.mealId]?.name ??
                                                  'Menu tidak tersedia',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(_entryPortion(entry)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  tooltip: 'Tambah menu ${shortDays[d]}',
                                  onPressed: widget.meals.isEmpty
                                      ? null
                                      : () => _addAt(
                                          calendarDay(monday, d),
                                          [7, 12, 16, 19][period],
                                        ),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _nutrition() {
    final entries = _dayEntries.where((e) => !_onlyEaten || e.isEaten).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Dimakan'),
              selected: _onlyEaten,
              onSelected: (_) => setState(() => _onlyEaten = true),
            ),
            ChoiceChip(
              label: const Text('Rencana'),
              selected: !_onlyEaten,
              onSelected: (_) => setState(() => _onlyEaten = false),
            ),
            OutlinedButton.icon(
              onPressed: _goals,
              icon: const Icon(Icons.tune),
              label: const Text('Target & batas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        NutritionSummary(
          entries: entries,
          meals: widget.meals,
          goals: widget.goals,
          focus: widget.focus,
          allNutrients: true,
        ),
        const SizedBox(height: 16),
        NutritionTrend(
          entries: widget.entries,
          meals: widget.meals,
          date: _date,
        ),
        const SizedBox(height: 16),
        Text('Catatan makan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: widget.meals.isEmpty ? null : () => _edit(eaten: true),
          icon: const Icon(Icons.add_task),
          label: const Text('Catat makan'),
        ),
        const SizedBox(height: 12),
        if (!_dayEntries.any((e) => e.isEaten))
          const Text('Belum ada menu yang ditandai dimakan pada tanggal ini'),
        for (final entry in _dayEntries.where((e) => e.isEaten)) _entry(entry),
      ],
    );
  }

  Widget _main() => LayoutBuilder(
    builder: (context, constraints) {
      final gutter = windowSizeFor(constraints.maxWidth) == WindowSize.compact
          ? 12.0
          : 16.0;
      return ListView(
        key: PageStorageKey('meal_section_$_section'),
        padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 32),
        children: [
          _navigation(),
          const SizedBox(height: 12),
          if (_section == 0)
            _header(context)
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _section == 1 ? 'Catatan gizi' : 'Jelajah menu',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _section == 1
                        ? 'Asupan dan target harian dalam satu tempat'
                        : 'Temukan pilihan masak dan beli untuk harimu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          if (_section != 2) ...[const SizedBox(height: 8), _dateBar()],
          const SizedBox(height: 12),
          if (_section == 0) _calendar(),
          if (_section == 1) ...[
            Align(alignment: Alignment.centerLeft, child: _focusButton()),
            const SizedBox(height: 8),
            _nutrition(),
          ],
          if (_section == 2) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [_focusButton(), _preferencesButton()],
            ),
            const SizedBox(height: 8),
            MealCatalog(
              meals: widget.meals,
              allergies: widget.allergies,
              focus: widget.focus,
              preferences: widget.preferences,
              onSelect: (meal) => _edit(meal: meal),
              onDetail: _detail,
            ),
          ],
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) => ResponsiveLayout(
    compact: (_) => _main(),
    medium: (_) => _main(),
    expanded: (_) => _section == 0 && _week
        ? _main()
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _main()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 16, 16, 110),
                  children: [
                    Text(
                      mealDateLabel(_date),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    NutritionSummary(
                      entries: _dayEntries.where((e) => e.isEaten).toList(),
                      meals: widget.meals,
                      goals: widget.goals,
                      focus: widget.focus,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _goals,
                      child: const Text('Atur target harian'),
                    ),
                  ],
                ),
              ),
            ],
          ),
  );
}
