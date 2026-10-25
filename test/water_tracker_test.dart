import 'package:budget_bites/screens/water_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

    await tester.tap(find.text('+250 ml'));
    expect(added, 250);
  });

  testWidgets('menampilkan empty state dan status target tercapai',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WaterTrackerScreen(currentWaterMl: 2000),
        ),
      ),
    );

    expect(find.text('Belum ada catatan minum hari ini'), findsOneWidget);
    expect(find.text('Target tercapai'), findsOneWidget);
  });
}