import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/screens/meal_plan_screen.dart';
import 'package:budget_bites/screens/profile_screen.dart';
import 'package:budget_bites/theme/app_theme.dart';
import 'package:budget_bites/widgets/main_navigation.dart';
import 'package:budget_bites/widgets/meal_card.dart';
import 'package:budget_bites/widgets/meal_catalog.dart';
import 'package:budget_bites/widgets/meal_preferences_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapVisible(
  WidgetTester tester,
  Finder finder, {
  double scrollDelta = 200,
}) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      scrollDelta,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

Widget app({double scale = 1}) => MaterialApp(
  theme: AppTheme.lightTheme,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: const MainNavigation(initialIndex: 1),
);

void main() {
  testWidgets('preferences apply to catalog and profile, can cancel and undo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Preferensi makan'));
    await tapVisible(tester, find.widgetWithText(FilterChip, 'Susu'));
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Vegan'));
    final price = find.widgetWithText(
      TextFormField,
      'Anggaran maksimal per porsi',
    );
    final minutes = find.widgetWithText(TextFormField, 'Waktu masak maksimal');
    await tester.ensureVisible(price);
    await tester.enterText(price, '-1');
    await tester.ensureVisible(minutes);
    await tester.enterText(minutes, '20');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Simpan preferensi'));
    expect(find.byType(MealPreferencesSheet), findsOneWidget);
    expect(find.textContaining('Isi angka bulat'), findsOneWidget);
    await tester.ensureVisible(price);
    await tester.enterText(price, '12000');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Simpan preferensi'));
    var screen = tester.widget<MealPlanScreen>(find.byType(MealPlanScreen));
    expect(screen.allergies.toSet(), {'Kacang', 'Susu'});
    expect(screen.preferences.diet, MealDiet.vegan);
    expect(screen.preferences.maxPrice, 12000);
    expect(screen.preferences.maxCookMinutes, 20);
    await tapVisible(
      tester,
      find.byKey(const ValueKey('meal_section_button_2')),
      scrollDelta: -200,
    );
    final cards = tester.widgetList<MealCard>(
      find.descendant(
        of: find.byType(MealCatalog),
        matching: find.byType(MealCard),
      ),
    );
    expect(cards, isNotEmpty);
    expect(
      cards.every(
        (c) =>
            c.meal.diet == MealDiet.vegan &&
            c.meal.price <= 12000 &&
            c.meal.cookTimeMinutes <= 20 &&
            !c.hasAllergy,
      ),
      isTrue,
    );
    await tapVisible(tester, find.text('Urungkan'));
    screen = tester.widget<MealPlanScreen>(find.byType(MealPlanScreen));
    expect(screen.preferences.diet, isNull);
    expect(screen.allergies, ['Kacang']);
    await tapVisible(tester, find.text('Profil'));
    var profile = tester.widget<ProfileScreen>(find.byType(ProfileScreen));
    expect(profile.profile.allergies, ['Kacang']);
    await tapVisible(tester, find.text('Ubah preferensi makan'));
    await tapVisible(tester, find.widgetWithText(FilterChip, 'Telur'));
    await tapVisible(tester, find.byTooltip('Tutup tanpa menyimpan'));
    profile = tester.widget<ProfileScreen>(find.byType(ProfileScreen));
    expect(profile.profile.allergies, ['Kacang']);
  });

  testWidgets(
    'preference sheet reflows on phones and tablets with keyboard and large text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      for (final size in [
        const Size(360, 740),
        const Size(700, 900),
        const Size(1100, 900),
      ]) {
        tester.view.physicalSize = size;
        tester.view.viewInsets = FakeViewPadding.zero;
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(app(scale: 1.6));
        await tester.pumpAndSettle();
        await tapVisible(tester, find.text('Preferensi makan'));
        expect(tester.takeException(), isNull);
        final price = find.widgetWithText(
          TextFormField,
          'Anggaran maksimal per porsi',
        );
        await tester.ensureVisible(price);
        await tester.enterText(price, '10000');
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await tapVisible(tester, find.text('Simpan preferensi'));
        expect(tester.takeException(), isNull);
        expect(find.byType(MealPreferencesSheet), findsNothing);
        expect(
          tester
              .widget<MealPlanScreen>(find.byType(MealPlanScreen))
              .preferences
              .maxPrice,
          10000,
        );
      }
    },
  );
}
