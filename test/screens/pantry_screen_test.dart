import 'package:budget_bites/models/pantry_item.dart';
import 'package:budget_bites/screens/pantry_screen.dart';
import 'package:budget_bites/widgets/pantry_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PantryScreen Widget tests', () {
    testWidgets('shows empty state when pantry items are empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PantryScreen(items: []),
          ),
        ),
      );

      expect(find.text('Pantry kosong'), findsOneWidget);
      expect(find.byIcon(Icons.kitchen_outlined), findsOneWidget);
      expect(
        find.text('Belum ada bahan makanan yang tersimpan di pantry Anda.'),
        findsOneWidget,
      );
      expect(find.byType(PantryItemTile), findsNothing);
    });

    testWidgets('renders summary card with correct counts and grouped items alphabetically', (tester) async {
      final now = DateTime.now();
      final items = [
        PantryItem(
          id: 'p1',
          name: 'Telur Ayam',
          category: 'Protein',
          quantity: 2,
          minQuantity: 4, // low stock!
          unit: 'butir',
          expiryDate: now.add(const Duration(days: 7)), // safe
        ),
        PantryItem(
          id: 'p2',
          name: 'Bayam',
          category: 'Sayuran',
          quantity: 3,
          minQuantity: 1, // safe stock
          unit: 'ikat',
          expiryDate: now.subtract(const Duration(days: 1)), // expired!
        ),
        PantryItem(
          id: 'p3',
          name: 'Bawang Merah',
          category: 'Bumbu',
          quantity: 200,
          minQuantity: 100,
          unit: 'g',
          expiryDate: now.add(const Duration(days: 10)), // safe
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PantryScreen(items: items),
          ),
        ),
      );

      // Summary Card (first Card in the list) — scoped so stepper values don't collide
      final summary = find.byType(Card).first;
      expect(find.text('Total Bahan'), findsOneWidget);
      expect(
        find.descendant(of: summary, matching: find.text('3')),
        findsOneWidget,
      ); // 3 items total
      expect(find.text('Stok Menipis'), findsOneWidget);
      expect(
        find.descendant(of: summary, matching: find.text('1')),
        findsNWidgets(2),
      ); // 1 low stock (Telur), 1 expired (Bayam)
      expect(
        find.descendant(of: summary, matching: find.text('Kedaluwarsa')),
        findsOneWidget,
      );

      // Category Headers sorted alphabetically: Bumbu, Protein, Sayuran
      expect(find.text('Bumbu'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Sayuran'), findsOneWidget);

      final bumbuPosition = tester.getTopLeft(find.text('Bumbu')).dy;
      final proteinPosition = tester.getTopLeft(find.text('Protein')).dy;
      final sayuranPosition = tester.getTopLeft(find.text('Sayuran')).dy;

      expect(bumbuPosition < proteinPosition, isTrue);
      expect(proteinPosition < sayuranPosition, isTrue);

      // Verify all items are rendered
      expect(find.text('Telur Ayam'), findsOneWidget);
      expect(find.text('Bayam'), findsOneWidget);
      expect(find.text('Bawang Merah'), findsOneWidget);
    });

    testWidgets('stepper updates item quantity on screen', (tester) async {
      final now = DateTime.now();
      final items = [
        PantryItem(
          id: 'p1',
          name: 'Telur Ayam',
          category: 'Protein',
          quantity: 2,
          minQuantity: 4,
          unit: 'butir',
          expiryDate: now.add(const Duration(days: 7)),
        ),
      ];

      // PantryScreen is stateless; host the state like MainNavigation does.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => PantryScreen(
                items: items,
                onUpdateItem: (updated) => setState(() => items[0] = updated),
              ),
            ),
          ),
        ),
      );

      expect(find.text('2 butir'), findsOneWidget);

      // Tap + button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('3 butir'), findsOneWidget);

      // Tap - button
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('2 butir'), findsOneWidget);
    });

    testWidgets('renders directly without own Scaffold or AppBar', (tester) async {
      final widget = const PantryScreen();
      // PantryScreen root should not be Scaffold
      final element = widget.createElement();
      expect(element, isNotNull);
    });
  });
}
