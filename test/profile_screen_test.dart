import 'package:budget_bites/models/user_profile.dart';
import 'package:budget_bites/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _profile = UserProfile(
  weeklyBudget: 300000,
  waterTargetMl: 2000,
  allergies: ['Kacang'],
  preferences: ['Hemat'],
);

Widget _wrap(ProfileScreen screen) {
  return MaterialApp(home: Scaffold(body: screen));
}

void main() {
  testWidgets('memilih alergi menambah item tanpa menghapus yang lama', (
    tester,
  ) async {
    UserProfile? updated;
    await tester.pumpWidget(
      _wrap(
        ProfileScreen(profile: _profile, onUpdateProfile: (p) => updated = p),
      ),
    );

    await tester.ensureVisible(find.text('Telur'));
    await tester.tap(find.text('Telur'));
    await tester.pump();

    expect(updated, isNotNull);
    expect(updated!.allergies, containsAll(['Kacang', 'Telur']));
  });

  testWidgets('menghapus pilihan alergi', (tester) async {
    UserProfile? updated;
    await tester.pumpWidget(
      _wrap(
        ProfileScreen(profile: _profile, onUpdateProfile: (p) => updated = p),
      ),
    );

    await tester.ensureVisible(find.text('Kacang'));
    await tester.tap(find.text('Kacang'));
    await tester.pump();

    expect(updated!.allergies, isEmpty);
  });

  testWidgets('sakelar mode gelap mengirim darkMode true', (tester) async {
    UserProfile? updated;
    await tester.pumpWidget(
      _wrap(
        ProfileScreen(profile: _profile, onUpdateProfile: (p) => updated = p),
      ),
    );

    await tester.ensureVisible(find.text('Mode Gelap'));
    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(updated!.darkMode, isTrue);
  });

  testWidgets('geser slider budget mengirim budget baru saat dilepas', (
    tester,
  ) async {
    UserProfile? updated;
    await tester.pumpWidget(
      _wrap(
        ProfileScreen(profile: _profile, onUpdateProfile: (p) => updated = p),
      ),
    );

    await tester.drag(find.byType(Slider).first, const Offset(60, 0));
    await tester.pump();

    expect(updated, isNotNull);
    expect(updated!.weeklyBudget, greaterThan(300000));
    expect(updated!.weeklyBudget % ProfileScreen.budgetStep, 0);
  });

  testWidgets('Reset Data Demo meminta konfirmasi lalu memanggil callback', (
    tester,
  ) async {
    var resetCount = 0;
    await tester.pumpWidget(
      _wrap(ProfileScreen(profile: _profile, onResetData: () => resetCount++)),
    );

    await tester.ensureVisible(find.text('Reset Data Demo'));
    await tester.tap(find.text('Reset Data Demo'));
    await tester.pumpAndSettle();

    expect(find.text('Reset data demo?'), findsOneWidget);
    expect(resetCount, 0);

    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await tester.pumpAndSettle();

    expect(resetCount, 1);
  });
}
