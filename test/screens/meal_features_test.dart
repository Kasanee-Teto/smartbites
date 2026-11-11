import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/models/planned_meal.dart';
import 'package:budget_bites/screens/meal_detail_screen.dart';
import 'package:budget_bites/screens/meal_plan_screen.dart';
import 'package:budget_bites/theme/app_theme.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/widgets/main_navigation.dart';
import 'package:budget_bites/widgets/meal_card.dart';
import 'package:budget_bites/widgets/meal_catalog.dart';
import 'package:budget_bites/widgets/meal_editor_sheet.dart';
import 'package:budget_bites/widgets/nutrition_goals_sheet.dart';
import 'package:budget_bites/widgets/nutrition_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      180,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 30,
    );
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

Widget _app(Widget home, {double scale = 1}) => MaterialApp(
  theme: AppTheme.lightTheme,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: home,
);

void main() {
  testWidgets(
    'focus picker reorders the day and weekly slot without moving meals',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 1500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final meals = mockCookMeals.take(3).toList();
      final entries = [
        for (final index in [2, 0, 1])
          PlannedMeal(
            id: 'entry_$index',
            mealId: meals[index].id,
            scheduledAt: DateTime(
              2020,
              1,
              1,
              index == 2
                  ? 7
                  : index == 0
                  ? 8
                  : 9,
            ),
          ),
      ];
      var focus = NutritionFocus.general;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => MealPlanScreen(
                entries: entries,
                meals: meals,
                goals: const {},
                focus: focus,
                initialDate: DateTime(2020),
                onSave: (_) {},
                onDelete: (_) {},
                onGoalsChanged: (_) {},
                onAddToGrocery: (_, _) {},
                onFocusChanged: (value) => setState(() => focus = value),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      List<String> cardIds() => tester
          .widgetList<MealCard>(find.byType(MealCard))
          .map((card) => card.meal.id)
          .toList();
      expect(cardIds(), ['m3', 'm1', 'm2']);
      await _tap(tester, find.text('Fokus: Umum'));
      await _tap(tester, find.text('Kolesterol'));
      expect(cardIds(), ['m1', 'm2', 'm3']);
      await _tap(tester, find.text('Fokus: Kolesterol'));
      await _tap(tester, find.text('Jantung'));
      expect(cardIds(), ['m1', 'm3', 'm2']);
      await _tap(tester, find.widgetWithText(ChoiceChip, 'Minggu'));
      expect(
        tester.getTopLeft(find.text(meals[0].name)).dy,
        lessThan(tester.getTopLeft(find.text(meals[2].name)).dy),
      );
      expect(
        tester.getTopLeft(find.text(meals[2].name)).dy,
        lessThan(tester.getTopLeft(find.text(meals[1].name)).dy),
      );
      await _tap(tester, find.text('Fokus: Jantung'));
      await _tap(tester, find.text('Umum'));
      await _tap(tester, find.widgetWithText(ChoiceChip, 'Hari'));
      expect(cardIds(), ['m3', 'm1', 'm2']);
      expect(entries.map((e) => e.scheduledAt.hour), [7, 8, 9]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'snapshot uses personal goals and never invents unknown progress',
    (tester) async {
      final meal = mockCookMeals.first;
      Widget snapshot({
        required bool missing,
        required Map<Nutrient, double> goals,
      }) => _app(
        Scaffold(
          body: SingleChildScrollView(
            child: NutritionSummary(
              entries: [
                PlannedMeal(
                  id: 'entry',
                  mealId: missing ? 'missing' : meal.id,
                  scheduledAt: DateTime(2020),
                ),
              ],
              meals: [meal],
              goals: goals,
              allNutrients: true,
            ),
          ),
        ),
      );
      await tester.pumpWidget(snapshot(missing: false, goals: {}));
      await tester.pumpAndSettle();
      expect(find.text('Energi & makro'), findsOneWidget);
      expect(
        tester
            .widgetList<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .every((ring) => ring.value == 0),
        isTrue,
      );
      await tester.pumpWidget(
        snapshot(missing: false, goals: {Nutrient.calories: 2000}),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .first
            .value,
        meal.calories / 2000,
      );
      await tester.pumpWidget(
        snapshot(missing: true, goals: {Nutrient.calories: 2000}),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .every((ring) => ring.value == 0),
        isTrue,
      );
      expect(find.text('Data 0/1'), findsWidgets);
    },
  );

  testWidgets('goal form validates off-screen values before saving', (
    tester,
  ) async {
    var saved = <Nutrient, double>{};
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final result =
                    await showModalBottomSheet<Map<Nutrient, double>>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const NutritionGoalsSheet(goals: {}),
                    );
                if (result != null) saved = result;
              },
              child: const Text('Open goals'),
            ),
          ),
        ),
      ),
    );
    await _tap(tester, find.text('Open goals'));
    final energy = find.widgetWithText(
      TextFormField,
      'Target ${Nutrient.calories.label}',
    );
    await tester.enterText(energy, '0');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Target Protein'),
      '50',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final scrollable = find
        .descendant(
          of: find.byType(NutritionGoalsSheet),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Simpan target'),
      300,
      scrollable: scrollable,
    );
    await _tap(tester, find.text('Simpan target'));
    expect(saved, isEmpty);
    expect(find.byType(NutritionGoalsSheet), findsOneWidget);
    await tester.scrollUntilVisible(energy, -300, scrollable: scrollable);
    await tester.enterText(energy, '1800');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Simpan target'),
      300,
      scrollable: scrollable,
    );
    await _tap(tester, find.text('Simpan target'));
    expect(saved[Nutrient.calories], 1800);
    expect(saved[Nutrient.protein], 50);
  });

  testWidgets('nutrition view selection survives a responsive breakpoint', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(const MainNavigation(initialIndex: 1)));
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const ValueKey('meal_section_button_1')));
    tester.view.physicalSize = const Size(1100, 900);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ChoiceChip, 'Dimakan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('meal editor remains scrollable above a phone keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: MealEditorSheet(meals: [mockMeals.first], date: DateTime(2020)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Simpan menu'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Simpan menu').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('planner is usable at compact, medium, expanded and large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final (size, expectedGap) in [
      (const Size(360, 740), 4.0),
      (const Size(700, 900), 4.0),
      (const Size(1280, 900), 8.0),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _app(const MainNavigation(initialIndex: 1), scale: 1.6),
      );
      await tester.pumpAndSettle();
      expect(find.text('Menu & Gizi'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final dayBounds = [
        for (final day in shortDays)
          tester.getRect(find.widgetWithText(InkWell, day)),
      ];
      for (var day = 1; day < dayBounds.length; day++) {
        expect(
          dayBounds[day].left - dayBounds[day - 1].right,
          closeTo(expectedGap, 0.01),
          reason: 'Day spacing at $size',
        );
      }
      await _tap(tester, find.text('Fokus: Umum'));
      final selectedTile = find.widgetWithText(ListTile, 'Umum');
      final nextTile = find.widgetWithText(ListTile, 'Kolesterol');
      expect(tester.widget<ListTile>(selectedTile).selected, isTrue);
      expect(
        tester.getTopLeft(nextTile).dy - tester.getBottomLeft(selectedTile).dy,
        4.0,
        reason: 'Focus tile spacing at $size',
      );
      await _tap(tester, selectedTile);
      final nutritionTab = find.byKey(const ValueKey('meal_section_button_1'));
      await tester.scrollUntilVisible(
        nutritionTab,
        -250,
        scrollable: find.byType(Scrollable).first,
      );
      await _tap(tester, nutritionTab);
      expect(tester.takeException(), isNull);
      await _tap(tester, find.byKey(const ValueKey('meal_section_button_0')));
      await _tap(tester, find.widgetWithText(ChoiceChip, 'Minggu'));
      expect(find.byType(Table), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('meal_section_button_2')),
        -250,
        scrollable: find.byType(Scrollable).first,
      );
      await _tap(tester, find.byKey(const ValueKey('meal_section_button_2')));
      await _tap(tester, find.text('Saring pilihan'));
      await _tap(tester, find.widgetWithText(ChoiceChip, 'Camilan'));
      final cards = tester.widgetList<MealCard>(
        find.descendant(
          of: find.byType(MealCatalog),
          matching: find.byType(MealCard),
        ),
      );
      expect(cards, isNotEmpty);
      expect(cards.every((card) => card.meal.category == 'Camilan'), isTrue);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('shared plan edits and meal logging can be undone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(const MainNavigation(initialIndex: 1)));
    await tester.pumpAndSettle();
    var screen = tester.widget<MealPlanScreen>(find.byType(MealPlanScreen));
    final previous = screen.entries.first;
    screen.onSave(previous.copyWith(servings: 1.5, isEaten: !previous.isEaten));
    await tester.pumpAndSettle();
    screen = tester.widget<MealPlanScreen>(find.byType(MealPlanScreen));
    expect(screen.entries.firstWhere((e) => e.id == previous.id).servings, 1.5);
    await _tap(tester, find.text('Urungkan'));
    screen = tester.widget<MealPlanScreen>(find.byType(MealPlanScreen));
    final restored = screen.entries.firstWhere((e) => e.id == previous.id);
    expect(restored.servings, previous.servings);
    expect(restored.isEaten, previous.isEaten);
    screen.onDelete(previous.id);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MealPlanScreen>(find.byType(MealPlanScreen))
          .entries
          .any((e) => e.id == previous.id),
      isFalse,
    );
    await _tap(tester, find.text('Urungkan'));
    expect(
      tester
          .widget<MealPlanScreen>(find.byType(MealPlanScreen))
          .entries
          .any((e) => e.id == previous.id),
      isTrue,
    );
  });

  testWidgets('catalog selection validates portions then schedules a meal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(const MainNavigation(initialIndex: 1)));
    await tester.pumpAndSettle();
    final before = tester
        .widget<MealPlanScreen>(find.byType(MealPlanScreen))
        .entries
        .length;
    await _tap(tester, find.byKey(const ValueKey('meal_section_button_2')));
    final search = find.widgetWithText(TextField, 'Cari menu Indonesia');
    await tester.scrollUntilVisible(
      search,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(search);
    await tester.enterText(search, 'Es Teler');
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Pilih menu'));
    final portions = find.widgetWithText(TextFormField, 'Jumlah porsi');
    await tester.enterText(portions, '0');
    await _tap(tester, find.text('Simpan menu'));
    expect(find.text('Masukkan 0,25 sampai 10 porsi'), findsOneWidget);
    await tester.enterText(portions, '1,5');
    await _tap(tester, find.text('Simpan menu'));
    final entries = tester
        .widget<MealPlanScreen>(find.byType(MealPlanScreen))
        .entries;
    expect(entries.length, before + 1);
    expect(entries.last.servings, 1.5);
    expect(entries.last.mealId, 'm81');
    expect(tester.takeException(), isNull);
  });

  testWidgets('bought menu detail has nutrition without recipe actions', (
    tester,
  ) async {
    await tester.pumpWidget(_app(MealDetailScreen(meal: mockBuyMeals.first)));
    await tester.pumpAndSettle();
    expect(find.text('Tambah bahan ke belanja'), findsNothing);
    expect(find.text('Cara memasak'), findsNothing);
    expect(
      find.text('Daftar alergen contoh tidak menjamin bebas alergen.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('partial cholesterol data cannot appear within a chosen limit', (
    tester,
  ) async {
    final known = mockCookMeals.firstWhere(
      (m) => m.nutrition.cholesterolMilligrams != null,
    );
    final unknown = mockBuyMeals.firstWhere(
      (m) => m.nutrition.cholesterolMilligrams == null,
    );
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: SingleChildScrollView(
            child: NutritionSummary(
              entries: [
                PlannedMeal(
                  id: 'a',
                  mealId: known.id,
                  scheduledAt: DateTime(2020),
                ),
                PlannedMeal(
                  id: 'b',
                  mealId: unknown.id,
                  scheduledAt: DateTime(2020),
                ),
              ],
              meals: [known, unknown],
              goals: const {Nutrient.cholesterol: 300},
              focus: NutritionFocus.cholesterol,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Data belum lengkap'), findsOneWidget);
    expect(find.textContaining('Dalam batas pilihan'), findsNothing);
    expect(find.text('Data tersedia: 1/2 menu'), findsOneWidget);
  });

  testWidgets('cholesterol cap excludes bought meals with unknown amounts', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: SingleChildScrollView(
            child: MealCatalog(
              meals: mockBuyMeals,
              allergies: const [],
              focus: NutritionFocus.cholesterol,
              onSelect: (_) {},
              onDetail: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Saring pilihan'));
    final cap = find.widgetWithText(TextField, 'Kolesterol maksimal per porsi');
    await tester.ensureVisible(cap);
    await tester.enterText(cap, '300');
    await tester.pumpAndSettle();
    expect(find.byType(MealCard), findsNothing);
    expect(
      find.textContaining('Belum ada menu sesuai pencarian'),
      findsOneWidget,
    );
  });

  testWidgets('future-dated entries cannot be recorded as eaten', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: MealEditorSheet(
            meals: [mockMeals.first],
            date: calendarDay(DateTime.now(), 2),
            initialEaten: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Simpan menu'));
    expect(
      find.text('Tanggal mendatang belum bisa dicatat dimakan'),
      findsOneWidget,
    );
  });
}
