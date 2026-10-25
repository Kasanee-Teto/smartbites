import 'package:budget_bites/models/daily_log.dart';
import 'package:budget_bites/utils/badge_rules.dart';
import 'package:flutter_test/flutter_test.dart';

DailyLog log(DateTime date, {int water = 0, bool noWaste = false}) {
  return DailyLog(
    date: date,
    waterMl: water,
    mealsEaten: const [],
    wasteLogged: false,
    noWasteMarked: noWaste,
  );
}

void main() {
  test('streak berjalan menghitung hari berturut-turut', () {
    final logs = [
      log(DateTime(2026, 10, 23), water: 250),
      log(DateTime(2026, 10, 24), water: 250),
      log(DateTime(2026, 10, 25), water: 250),
    ];
    expect(BadgeRules.currentStreak(logs, DateTime(2026, 10, 25)), 3);
  });

  test('hari ini kosong tidak langsung memutus streak', () {
    final logs = [
      log(DateTime(2026, 10, 23), water: 250),
      log(DateTime(2026, 10, 24), water: 250),
    ];
    expect(BadgeRules.currentStreak(logs, DateTime(2026, 10, 25)), 2);
  });

  test('longestRun memutus saat ada hari yang terlewat', () {
    final days = {
      DateTime(2026, 10, 1),
      DateTime(2026, 10, 2),
      DateTime(2026, 10, 4),
    };
    expect(BadgeRules.longestRun(days), 2);
  });

  test('evaluate membuka Langkah Pertama dan Streak 3 Hari', () {
    final result = BadgeRules.evaluate(
      logs: [
        log(DateTime(2026, 10, 23), water: 250),
        log(DateTime(2026, 10, 24), water: 250),
        log(DateTime(2026, 10, 25), water: 250),
      ],
      waterTargetMl: 2000,
      weekPlan: const [],
      meals: const [],
      weeklyBudget: 300000,
      grocery: const [],
    );
    final byId = {for (final a in result) a.id: a};
    expect(result.length, 8);
    expect(byId[BadgeRules.firstStep]!.isUnlocked, isTrue);
    expect(byId[BadgeRules.streak3]!.isUnlocked, isTrue);
    expect(byId[BadgeRules.streak7]!.isUnlocked, isFalse);
    expect(byId[BadgeRules.streak7]!.progress, 3);
  });
}