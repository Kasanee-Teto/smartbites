import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/nutrition_facts.dart';
import 'package:budget_bites/models/waste_record.dart';
import 'package:budget_bites/screens/food_waste_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _gado = Meal(
  id: 'm2',
  name: 'Gado-Gado Komplit',
  category: 'Makan Siang',
  imageAsset: 'assets/images/meal_gado_gado.png',
  price: 15000,
  calories: 380,
  nutrition: NutritionFacts(
    servingSize: '1 porsi',
    servingSizeGrams: 300,
    totalFatGrams: 10,
    saturatedFatGrams: 2,
    sodiumMilligrams: 300,
    carbohydrateGrams: 40,
    fiberGrams: 6,
    totalSugarsGrams: 8,
    proteinGrams: 12,
  ),
  cookTimeMinutes: 20,
  ingredients: ['Tahu 100g'],
  allergens: ['Kacang'],
  steps: ['Rebus sayuran'],
);

Widget _wrap(Widget screen) {
  return MaterialApp(home: Scaffold(body: screen));
}

void main() {
  testWidgets('pilih chip mengisi harga otomatis dan mencatat record', (
    tester,
  ) async {
    WasteRecord? added;
    await tester.pumpWidget(
      _wrap(
        FoodWasteScreen(
          recentMeals: const [_gado],
          onAddRecord: (r) => added = r,
        ),
      ),
    );

    await tester.tap(find.text('Gado-Gado Komplit'));
    await tester.pump();
    expect(find.text('7500'), findsOneWidget); // porsi bawaan: Setengah

    await tester.tap(find.text('Sedikit'));
    await tester.pump();
    expect(find.text('3750'), findsOneWidget);

    await tester.ensureVisible(find.text('Catat Makanan Terbuang').last);
    await tester.tap(find.text('Catat Makanan Terbuang').last);
    await tester.pump();

    expect(added, isNotNull);
    expect(added!.itemName, 'Gado-Gado Komplit');
    expect(added!.portion, WastePortions.sedikit);
    expect(added!.estimatedLoss, 3750);
  });

  testWidgets('nama kosong menampilkan error dan tidak mencatat', (
    tester,
  ) async {
    WasteRecord? added;
    await tester.pumpWidget(
      _wrap(FoodWasteScreen(onAddRecord: (r) => added = r)),
    );

    await tester.ensureVisible(find.text('Catat Makanan Terbuang').last);
    await tester.tap(find.text('Catat Makanan Terbuang').last);
    await tester.pump();

    expect(find.text('Nama item wajib diisi'), findsOneWidget);
    expect(added, isNull);
  });

  testWidgets('total kerugian hanya menghitung bulan berjalan', (tester) async {
    await tester.pumpWidget(
      _wrap(
        FoodWasteScreen(
          now: DateTime(2026, 10, 25),
          records: [
            WasteRecord(
              id: 'a',
              itemName: 'Sawi Putih',
              portion: WastePortions.sedikit,
              estimatedLoss: 3000,
              date: DateTime(2026, 10, 18),
            ),
            WasteRecord(
              id: 'b',
              itemName: 'Nasi Putih',
              portion: WastePortions.setengah,
              estimatedLoss: 2500,
              date: DateTime(2026, 10, 17),
            ),
            WasteRecord(
              id: 'c',
              itemName: 'Tempe',
              portion: WastePortions.semua,
              estimatedLoss: 9000,
              date: DateTime(2026, 9, 30),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Rp 5.500'), findsOneWidget);
  });

  testWidgets('tombol tidak ada yang terbuang memanggil callback', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpWidget(
      _wrap(FoodWasteScreen(onMarkNoWaste: () => count++)),
    );

    await tester.ensureVisible(find.text('Tidak ada yang terbuang hari ini'));
    await tester.tap(find.text('Tidak ada yang terbuang hari ini'));
    await tester.pump();

    expect(count, 1);
  });

  testWidgets('sudah ditandai: tombol nonaktif dan muncul status Tercatat', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpWidget(
      _wrap(FoodWasteScreen(noWasteMarked: true, onMarkNoWaste: () => count++)),
    );

    expect(find.text('Tercatat'), findsOneWidget);
    await tester.ensureVisible(find.text('Tidak ada yang terbuang hari ini'));
    await tester.tap(find.text('Tidak ada yang terbuang hari ini'));
    await tester.pump();

    expect(count, 0);
  });

  testWidgets('daftar kosong menampilkan empty state', (tester) async {
    await tester.pumpWidget(_wrap(const FoodWasteScreen()));

    expect(find.text('Belum ada catatan makanan terbuang'), findsOneWidget);
  });
}
