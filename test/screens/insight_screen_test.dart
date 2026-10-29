// Owner: Gilbert | Tests: InsightScreen (FR-07) & GroceryScreen (FR-14..FR-17)

import 'package:budget_bites/models/grocery_item.dart';
import 'package:budget_bites/screens/grocery_screen.dart';
import 'package:budget_bites/screens/insight_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InsightScreen Widget tests (FR-07)', () {
    testWidgets(
      'renders budget overview, 7-day bar chart, categories, and hemat status',
      (tester) async {
        var backCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: InsightScreen(
              currentSpent: 140000,
              onBack: () => backCalled = true,
            ),
          ),
        );

        expect(find.text('Insight Mingguan'), findsOneWidget);
        expect(find.text('Ringkasan Anggaran Mingguan'), findsOneWidget);
        expect(find.text('Hemat'), findsOneWidget);
        expect(find.text('Sisa Anggaran'), findsOneWidget);
        expect(find.text('Rp 160.000'), findsOneWidget);
        expect(find.text('Grafik Pengeluaran 7 Hari'), findsOneWidget);

        // Verify all 7 bar chart columns exist
        for (var i = 0; i < 7; i++) {
          expect(find.byKey(Key('insight_bar_$i')), findsOneWidget);
        }

        // Scroll to inspect lower cards on compact screen
        await tester.scrollUntilVisible(
          find.text('Alokasi Kategori Belanja'),
          200,
        );
        expect(find.text('Alokasi Kategori Belanja'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Tips Hemat & Anti-Mubazir'),
          200,
        );
        expect(find.text('Tips Hemat & Anti-Mubazir'), findsOneWidget);

        // Back button triggers callback
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();
        expect(backCalled, isTrue);
      },
    );

    testWidgets(
      'handles over-budget, zero budget, and expanded tablet layout cleanly',
      (tester) async {
        tester.view.physicalSize = const Size(1024 * 2.0, 768 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: MaterialApp(home: InsightScreen(currentSpent: 370000)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Perlu Hemat'), findsOneWidget);
        expect(find.text('Selisih Lebih'), findsOneWidget);
        expect(find.text('Rp 70.000'), findsOneWidget);

        // Zero budget & negative input resilience (NFR robustness)
        await tester.pumpWidget(
          const MaterialApp(
            home: InsightScreen(currentSpent: -5000, weeklyBudget: 0),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('GroceryScreen Widget & Input Validation tests (FR-14..FR-17)', () {
    testWidgets(
      'validates empty/whitespace input, adds trimmed item, and toggles/clears',
      (tester) async {
        GroceryItem? addedItem;
        String? toggledId;
        var clearCheckedCalled = false;

        const items = [
          GroceryItem(
            id: 'g1',
            name: 'Tempe Papan',
            quantity: 2,
            unit: 'papan',
            price: 10000,
            isChecked: true,
          ),
          GroceryItem(
            id: 'g2',
            name: 'Bayam Hijau',
            quantity: 1,
            unit: 'ikat',
            price: 4000,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GroceryScreen(
                items: items,
                onAddItem: (item) => addedItem = item,
                onToggleItem: (id) => toggledId = id,
                onClearChecked: () => clearCheckedCalled = true,
              ),
            ),
          ),
        );

        // Total price and checked count
        expect(find.text('Rp 14.000'), findsOneWidget);
        expect(find.text('1 dari 2 selesai'), findsOneWidget);

        // Whitespace-only input is rejected
        await tester.enterText(find.byType(TextField), '   ');
        await tester.tap(find.byTooltip('Tambah item'));
        await tester.pump();
        expect(addedItem, isNull);

        // Valid input with extra whitespace is trimmed and normalized
        await tester.enterText(find.byType(TextField), '  Telur   Ayam  ');
        await tester.tap(find.byTooltip('Tambah item'));
        await tester.pump();
        expect(addedItem, isNotNull);
        expect(addedItem!.name, 'Telur Ayam');

        // Move checked items to Pantry CTA button
        await tester.tap(find.text('Pindahkan 1 item ke Pantry'));
        await tester.pump();
        expect(clearCheckedCalled, isTrue);

        // Toggle item
        await tester.tap(find.text('Bayam Hijau'));
        await tester.pump();
        expect(toggledId, 'g2');
      },
    );
  });
}
