import 'package:budget_bites/models/pantry_item.dart';
import 'package:budget_bites/widgets/pantry_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PantryItemTile helper tests', () {
    test('formatExpiryDate formats date into dd MMM yyyy Indonesian format', () {
      final date = DateTime(2026, 10, 14);
      expect(formatExpiryDate(date), '14 Okt 2026');

      final dateJan = DateTime(2026, 1, 5);
      expect(formatExpiryDate(dateJan), '05 Jan 2026');

      final dateAgu = DateTime(2026, 8, 17);
      expect(formatExpiryDate(dateAgu), '17 Agu 2026');
    });

    test('getExpiryStatus correctly calculates safe, expiringSoon, and expired', () {
      final now = DateTime.now();

      // Past date -> expired
      final pastDate = now.subtract(const Duration(days: 2));
      expect(getExpiryStatus(pastDate), ExpiryStatus.expired);

      // Today -> expired (per FR-20: 'expiry is today or past')
      expect(getExpiryStatus(now), ExpiryStatus.expired);

      // 1 to 3 days -> expiringSoon
      final soonDate1 = now.add(const Duration(days: 1));
      expect(getExpiryStatus(soonDate1), ExpiryStatus.expiringSoon);

      final soonDate3 = now.add(const Duration(days: 3));
      expect(getExpiryStatus(soonDate3), ExpiryStatus.expiringSoon);

      // More than 3 days -> safe
      final safeDate = now.add(const Duration(days: 5));
      expect(getExpiryStatus(safeDate), ExpiryStatus.safe);
    });
  });

  group('PantryItemTile Widget tests', () {
    testWidgets('renders item name, unit, and safe expiry badge', (tester) async {
      double changedQty = -1;
      final item = PantryItem(
        id: 'p1',
        name: 'Beras Pulen',
        category: 'Pokok',
        quantity: 5,
        minQuantity: 2,
        unit: 'kg',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PantryItemTile(
              item: item,
              onQuantityChanged: (val) => changedQty = val,
            ),
          ),
        ),
      );

      expect(find.text('Beras Pulen'), findsOneWidget);
      expect(find.text('5 kg'), findsOneWidget);
      expect(find.text('Aman'), findsOneWidget);
      expect(find.text('Stok menipis'), findsNothing);

      // Tap + button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(changedQty, 6.0);
    });

    testWidgets('renders low stock warning when quantity <= minQuantity', (tester) async {
      final item = PantryItem(
        id: 'p2',
        name: 'Tempe',
        category: 'Protein',
        quantity: 1,
        minQuantity: 2,
        unit: 'papan',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PantryItemTile(
              item: item,
              onQuantityChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Tempe'), findsOneWidget);
      expect(find.text('1 papan'), findsOneWidget);
      expect(find.text('Stok menipis'), findsOneWidget);
      expect(find.text('Segera habis'), findsOneWidget);
    });

    testWidgets('stepper cannot decrement below 0', (tester) async {
      double changedQty = -1;
      final item = PantryItem(
        id: 'p3',
        name: 'Telur',
        category: 'Protein',
        quantity: 0,
        minQuantity: 4,
        unit: 'butir',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PantryItemTile(
              item: item,
              onQuantityChanged: (val) => changedQty = val,
            ),
          ),
        ),
      );

      expect(find.text('Kedaluwarsa'), findsOneWidget);
      expect(find.text('0 butir'), findsOneWidget);

      // Decrement button should be disabled when quantity is 0
      final removeButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.remove));
      expect(removeButton.onPressed, isNull);
      expect(changedQty, -1);
    });

    testWidgets('stepper decrements quantity when quantity > 0', (tester) async {
      double changedQty = -1;
      final item = PantryItem(
        id: 'p4',
        name: 'Tahu',
        category: 'Protein',
        quantity: 4,
        minQuantity: 2,
        unit: 'potong',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PantryItemTile(
              item: item,
              onQuantityChanged: (val) => changedQty = val,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(changedQty, 3.0);
    });
  });
}
