import 'package:budget_bites/screens/achievements_screen.dart';
import 'package:budget_bites/utils/badge_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final badges = [
    BadgeRules.catalog[0].copyWith(progress: 1, isUnlocked: true),
    BadgeRules.catalog[1].copyWith(progress: 3, isUnlocked: true),
    ...BadgeRules.catalog.skip(2),
  ];

  testWidgets('menampilkan 8 badge, jumlah terbuka, dan pesan streak', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AchievementsScreen(achievements: badges, currentStreak: 5),
      ),
    );

    expect(find.text('Langkah Pertama'), findsOneWidget);
    expect(find.text('Perencana Handal'), findsOneWidget);
    expect(find.text('Terbuka'), findsNWidgets(2));
    expect(find.text('2 dari 8 badge terbuka'), findsOneWidget);
    expect(find.text('2 hari lagi menuju Streak 7 Hari'), findsOneWidget);
  });

  testWidgets('streak 0 memakai bahasa ramah tanpa menyalahkan', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AchievementsScreen(achievements: BadgeRules.catalog),
      ),
    );

    expect(
      find.text('Mulai catatan hari ini, satu ketukan sudah cukup.'),
      findsOneWidget,
    );
    expect(find.text('0 dari 8 badge terbuka'), findsOneWidget);
  });

  testWidgets('daftar kosong menampilkan empty state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AchievementsScreen()));

    expect(
      find.text('Belum ada badge. Mulai mencatat untuk membukanya.'),
      findsOneWidget,
    );
  });

  testWidgets('tombol kembali memanggil onBack', (tester) async {
    var backCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AchievementsScreen(
          achievements: badges,
          onBack: () => backCount++,
        ),
      ),
    );

    await tester.tap(find.byType(BackButton));
    await tester.pump();

    expect(backCount, 1);
  });
}
