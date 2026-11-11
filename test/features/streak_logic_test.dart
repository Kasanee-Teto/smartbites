import 'package:budget_bites/models/daily_log.dart';
import 'package:budget_bites/utils/streak_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hasActivity unit tests', () {
    test('returns true when waterMl > 0', () {
      final log = DailyLog(
        date: DateTime(2026, 11, 6),
        waterMl: 250,
        mealsEaten: const [],
        wasteLogged: false,
        noWasteMarked: false,
      );
      expect(hasActivity(log), isTrue);
    });

    test('returns true when mealsEaten is not empty', () {
      final log = DailyLog(
        date: DateTime(2026, 11, 6),
        waterMl: 0,
        mealsEaten: const ['m1'],
        wasteLogged: false,
        noWasteMarked: false,
      );
      expect(hasActivity(log), isTrue);
    });

    test('returns true when wasteLogged is true', () {
      final log = DailyLog(
        date: DateTime(2026, 11, 6),
        waterMl: 0,
        mealsEaten: const [],
        wasteLogged: true,
        noWasteMarked: false,
      );
      expect(hasActivity(log), isTrue);
    });

    test('returns true when noWasteMarked is true', () {
      final log = DailyLog(
        date: DateTime(2026, 11, 6),
        waterMl: 0,
        mealsEaten: const [],
        wasteLogged: false,
        noWasteMarked: true,
      );
      expect(hasActivity(log), isTrue);
    });

    test('returns false when all activities are 0 or empty', () {
      final log = DailyLog(
        date: DateTime(2026, 11, 6),
        waterMl: 0,
        mealsEaten: const [],
        wasteLogged: false,
        noWasteMarked: false,
      );
      expect(hasActivity(log), isFalse);
    });
  });

  group('calculateStreak unit tests', () {
    final today = DateTime(2026, 11, 6, 14, 30);

    test('returns 0 for empty list', () {
      expect(calculateStreak([], today), 0);
    });

    test('returns 1 for today only', () {
      final logs = [
        DailyLog(
          date: DateTime(2026, 11, 6),
          waterMl: 500,
          mealsEaten: const [],
          wasteLogged: false,
          noWasteMarked: false,
        ),
      ];
      expect(calculateStreak(logs, today), 1);
    });

    test('returns 1 for yesterday only (streak stays alive)', () {
      final logs = [
        DailyLog(
          date: DateTime(2026, 11, 5),
          waterMl: 2000,
          mealsEaten: const [],
          wasteLogged: false,
          noWasteMarked: false,
        ),
      ];
      // Today (Nov 6) has no activity, but yesterday (Nov 5) had activity
      expect(calculateStreak(logs, today), 1);
    });

    test('resets streak when there is a gap', () {
      final logs = [
        // Today has activity
        DailyLog(
          date: DateTime(2026, 11, 6),
          waterMl: 250,
          mealsEaten: const [],
          wasteLogged: false,
          noWasteMarked: false,
        ),
        // Yesterday (Nov 5) is MISSING (gap)
        // 2 days ago has activity
        DailyLog(
          date: DateTime(2026, 11, 4),
          waterMl: 2000,
          mealsEaten: const ['m1'],
          wasteLogged: false,
          noWasteMarked: false,
        ),
      ];
      // Only today is counted because yesterday is a gap
      expect(calculateStreak(logs, today), 1);
    });

    test('handles duplicate dates properly', () {
      final logs = [
        // First entry for Nov 5 has no activity
        DailyLog(
          date: DateTime(2026, 11, 5),
          waterMl: 0,
          mealsEaten: const [],
          wasteLogged: false,
          noWasteMarked: false,
        ),
        // Second entry for Nov 5 has activity
        DailyLog(
          date: DateTime(2026, 11, 5),
          waterMl: 500,
          mealsEaten: const [],
          wasteLogged: false,
          noWasteMarked: false,
        ),
        // Today has activity
        DailyLog(
          date: DateTime(2026, 11, 6),
          waterMl: 250,
          mealsEaten: const [],
          wasteLogged: false,
          noWasteMarked: false,
        ),
      ];
      expect(calculateStreak(logs, today), 2);
    });

    test('ignores future dates', () {
      final logs = [
        // Tomorrow (Nov 7) has activity
        DailyLog(
          date: DateTime(2026, 11, 7),
          waterMl: 2000,
          mealsEaten: const ['m1'],
          wasteLogged: false,
          noWasteMarked: false,
        ),
      ];
      // Today and yesterday have no activity, future is ignored
      expect(calculateStreak(logs, today), 0);
    });

    test(
      'handles midnight boundary (23:59 vs 00:01) as consecutive calendar days',
      () {
        // Midnight boundary:
        // Day 1 log logged at 23:59
        final day1 = DateTime(2026, 11, 5, 23, 59);
        // Day 2 log logged at 00:01
        final day2 = DateTime(2026, 11, 6, 0, 1);

        final logs = [
          DailyLog(
            date: day1,
            waterMl: 1500,
            mealsEaten: const [],
            wasteLogged: false,
            noWasteMarked: false,
          ),
          DailyLog(
            date: day2,
            waterMl: 250,
            mealsEaten: const [],
            wasteLogged: false,
            noWasteMarked: false,
          ),
        ];

        // Current time is 00:05 on Day 2
        final nowAtMidnight = DateTime(2026, 11, 6, 0, 5);
        expect(calculateStreak(logs, nowAtMidnight), 2);
      },
    );

    test('calculates 5-day streak correctly', () {
      final logs = [
        for (var i = 4; i >= 0; i--)
          DailyLog(
            date: DateTime(2026, 11, 6 - i),
            waterMl: 1000,
            mealsEaten: const ['m1'],
            wasteLogged: false,
            noWasteMarked: false,
          ),
      ];
      expect(calculateStreak(logs, today), 5);
    });
  });

  group('streakLevel unit tests', () {
    test('streakLevel at 0, 2, 3, 6, 7', () {
      expect(streakLevel(0), 1);
      expect(streakLevel(2), 1);
      expect(streakLevel(3), 2);
      expect(streakLevel(6), 2);
      expect(streakLevel(7), 3);
    });

    test('streakLevel at higher values', () {
      expect(streakLevel(14), 3);
      expect(streakLevel(30), 3);
    });
  });

  group('nextBadgeProgress unit tests', () {
    test('when streak < 3 returns target 3 and current progress', () {
      expect(nextBadgeProgress(0), (target: 3, progress: 0));
      expect(nextBadgeProgress(1), (target: 3, progress: 1));
      expect(nextBadgeProgress(2), (target: 3, progress: 2));
    });

    test('when streak >= 3 returns target 7 and current progress up to 7', () {
      expect(nextBadgeProgress(3), (target: 7, progress: 3));
      expect(nextBadgeProgress(5), (target: 7, progress: 5));
      expect(nextBadgeProgress(6), (target: 7, progress: 6));
      expect(nextBadgeProgress(7), (target: 7, progress: 7));
      expect(nextBadgeProgress(10), (target: 7, progress: 7));
    });
  });
}
