import 'package:budget_bites/models/hydration_reminder.dart';
import 'package:budget_bites/models/water_record.dart';
import 'package:budget_bites/screens/hydration_settings_screen.dart';
import 'package:budget_bites/screens/water_tracker_screen.dart';
import 'package:budget_bites/utils/hydration.dart';
import 'package:budget_bites/widgets/app_bar.dart';
import 'package:budget_bites/widgets/drink_category_icon.dart';
import 'package:budget_bites/widgets/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scores apply signed weights and streaks use consecutive goal days', () {
    final today = DateTime(2026, 11, 11, 10);
    final records = [
      for (final category in DrinkCategory.values)
        WaterRecord(
          id: category.name,
          amountMl: category.defaultMl,
          time: today,
          category: category,
        ),
      WaterRecord(id: 'yesterday', amountMl: 900, time: DateTime(2026, 11, 10)),
      WaterRecord(id: 'gap', amountMl: 900, time: DateTime(2026, 11, 8)),
    ];
    expect(hydrationScore(drinksOn(records, today)), 870);
    expect(plainWaterMl(drinksOn(records, today)), 250);
    expect(hydrationStreak(records, today, 850), 2);
    expect(hydrationStreak(records, today, 900), 1);
    expect(
      hydrationScore(
        drinksOn(records, today).where((r) => r.category == DrinkCategory.wine),
      ),
      -75,
    );
  });

  test(
    'reminder respects overnight hours, inactivity, smart mode and snooze',
    () {
      const settings = HydrationReminder(
        enabled: true,
        startMinute: 22 * 60,
        endMinute: 8 * 60,
        interval: Duration(minutes: 30),
      );
      final anchor = DateTime(2026, 11, 10, 23, 30);
      final snooze = DateTime(2026, 11, 11, 0, 15);
      bool due(DateTime now, {double score = 300, DateTime? snoozedUntil}) =>
          settings.isDue(
            now: now,
            anchor: anchor,
            score: score,
            goal: 2000,
            snoozedUntil: snoozedUntil,
          );
      expect(due(DateTime(2026, 11, 10, 23, 59)), isFalse);
      expect(due(DateTime(2026, 11, 11)), isTrue);
      expect(due(DateTime(2026, 11, 11), score: 2000), isFalse);
      expect(due(DateTime(2026, 11, 11, 8)), isFalse);
      expect(due(DateTime(2026, 11, 11, 0, 14), snoozedUntil: snooze), isFalse);
      expect(due(snooze, snoozedUntil: snooze), isTrue);
    },
  );

  testWidgets('tombol +250 ml memanggil onAddWater', (tester) async {
    int? added;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WaterTrackerScreen(
            currentWaterMl: 500,
            onAddWater: (amount) => added = amount,
          ),
        ),
      ),
    );

    final water = find.widgetWithText(OutlinedButton, 'Air putih');
    await tester.ensureVisible(water);
    await tester.pumpAndSettle();
    await tester.tap(water);
    expect(added, 250);
  });

  testWidgets('menampilkan empty state dan status target tercapai', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: WaterTrackerScreen(currentWaterMl: 2000)),
      ),
    );

    expect(find.text('Belum ada catatan minum hari ini'), findsOneWidget);
    expect(find.text('Target tercapai'), findsOneWidget);
  });

  testWidgets('logs, edits and restores drinks through the Air tab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(
      const MaterialApp(home: MainNavigation(initialIndex: 3)),
    );
    await tester.pumpAndSettle();
    final appBar = find.byType(SmartBitesAppBar);
    final activityStreak = tester.widget<SmartBitesAppBar>(appBar).streakDays;
    await tap(find.widgetWithText(OutlinedButton, 'Kopi'));
    expect(find.text('120'), findsOneWidget);
    expect(tester.widget<SmartBitesAppBar>(appBar).streakDays, activityStreak);
    await tap(find.widgetWithText(OutlinedButton, 'Wine'));
    expect(find.text('45'), findsOneWidget);
    expect(
      find.textContaining('Skor hidrasi aplikasi berkurang'),
      findsOneWidget,
    );

    final wine = find.widgetWithText(ListTile, 'Wine');
    final menu = find.descendant(
      of: wine,
      matching: find.byTooltip('Opsi catatan'),
    );
    await tap(menu);
    await tap(find.text('Ubah'));
    await tap(find.widgetWithText(ChoiceChip, '330 ml'));
    await tap(find.text('Simpan catatan'));
    expect(find.text('-45'), findsOneWidget);
    expect(
      find.descendant(of: wine, matching: find.text('330 ml')),
      findsOneWidget,
    );

    await tap(menu);
    await tap(find.text('Hapus'));
    expect(wine, findsNothing);
    expect(find.text('120'), findsOneWidget);
    await tap(find.text('Urungkan'));
    expect(wine, findsOneWidget);

    await tap(find.text('Atur porsi'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Volume'), '137');
    await tap(find.text('Simpan catatan'));
    expect(find.text('92'), findsOneWidget);
    expect(find.text('137 ml'), findsOneWidget);

    await tap(find.text('Statistik'));
    expect(find.text('Skor hidrasi per hari'), findsOneWidget);
    expect(find.text('Jenis minuman'), findsOneWidget);
    expect(find.textContaining('minuman minggu ini'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tap(find.text('Pengingat'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Target hidrasi'),
      '2500',
    );
    await tap(find.text('Aktifkan pengingat'));
    expect(find.text('Mode pintar'), findsOneWidget);
    await tap(find.text('Simpan pengaturan'));
    expect(find.text('dari 2500 ml'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('drink cards and reminder rows have room at each screen size', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final (size, scale) in [
      (const Size(320, 720), 2.0),
      (const Size(768, 1024), 1.4),
      (const Size(1280, 800), 1.0),
    ]) {
      tester.view.physicalSize = size;
      Widget app(Widget home) => MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: home,
      );

      await tester.pumpWidget(app(const Scaffold(body: WaterTrackerScreen())));
      await tester.pumpAndSettle();
      Rect? previous;
      for (final category in DrinkCategory.values) {
        final card = find.widgetWithText(OutlinedButton, category.label);
        final cardBounds = tester.getRect(card);
        final icon = find.descendant(
          of: card,
          matching: find.byType(DrinkCategoryIcon),
        );
        final amount = find.descendant(
          of: card,
          matching: find.text('+${category.defaultMl} ml'),
        );
        expect(
          tester.getTopLeft(icon).dy - cardBounds.top,
          greaterThanOrEqualTo(13),
        );
        expect(
          cardBounds.bottom - tester.getBottomLeft(amount).dy,
          greaterThanOrEqualTo(13),
        );
        if (previous != null) {
          final sameRow = (cardBounds.top - previous.top).abs() < 0.01;
          final gap = sameRow
              ? cardBounds.left - previous.right
              : cardBounds.top - previous.bottom;
          expect(
            gap,
            greaterThanOrEqualTo(11.9),
            reason: 'Drink card gap at $size',
          );
        }
        previous = cardBounds;
      }
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        app(
          const HydrationSettingsScreen(
            goal: 2000,
            settings: HydrationReminder(enabled: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final title = find.text('Aktifkan pengingat');
      final tile = find.widgetWithText(SwitchListTile, 'Aktifkan pengingat');
      final toggle = find.descendant(of: tile, matching: find.byType(Switch));
      final bounds = tester.getRect(tile);
      expect(
        tester.getTopLeft(title).dx - bounds.left,
        greaterThanOrEqualTo(15),
      );
      expect(
        bounds.right - tester.getTopRight(toggle).dx,
        greaterThanOrEqualTo(15),
      );
      expect(
        tester.getTopLeft(toggle).dx - tester.getTopRight(title).dx,
        greaterThanOrEqualTo(8),
      );
      expect(
        tester.getTopLeft(title).dy - bounds.top,
        greaterThanOrEqualTo(11),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
