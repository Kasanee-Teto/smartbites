// Owner: Edbert | FR: FR-37

import 'package:budget_bites/models/achievement.dart';
import 'package:budget_bites/models/daily_log.dart';
import 'package:budget_bites/models/grocery_item.dart';
import 'package:budget_bites/models/meal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons;

class BadgeRules {
  BadgeRules._();

  static const String firstStep = 'first_step';
  static const String streak3 = 'streak_3';
  static const String streak7 = 'streak_7';
  static const String hydrationHero = 'hydration_hero';
  static const String masterPlanner = 'master_planner';
  static const String safeWallet = 'safe_wallet';
  static const String antiWasteHero = 'anti_waste_hero';
  static const String smartShopper = 'smart_shopper';

  static const List<Achievement> catalog = [
    Achievement(
      id: firstStep,
      title: 'Langkah Pertama',
      description: 'Buat catatan pertamamu',
      iconAsset: 'assets/icons/badge_first_step.png',
      target: 1,
      progress: 0,
    ),
    Achievement(
      id: streak3,
      title: 'Streak 3 Hari',
      description: 'Mencatat 3 hari berturut-turut',
      iconAsset: 'assets/icons/badge_streak_3.png',
      target: 3,
      progress: 0,
    ),
    Achievement(
      id: streak7,
      title: 'Streak 7 Hari',
      description: 'Mencatat 7 hari berturut-turut',
      iconAsset: 'assets/icons/badge_streak_7.png',
      target: 7,
      progress: 0,
    ),
    Achievement(
      id: hydrationHero,
      title: 'Hidrasi Hero',
      description: 'Capai target air selama 3 hari',
      iconAsset: 'assets/icons/badge_water.png',
      target: 3,
      progress: 0,
    ),
    Achievement(
      id: masterPlanner,
      title: 'Perencana Handal',
      description: 'Isi rencana makan penuh selama 1 minggu',
      iconAsset: 'assets/icons/badge_planner.png',
      target: 7,
      progress: 0,
    ),
    Achievement(
      id: safeWallet,
      title: 'Dompet Aman',
      description: 'Total rencana mingguan tidak melebihi budget',
      iconAsset: 'assets/icons/badge_budget.png',
      target: 1,
      progress: 0,
    ),
    Achievement(
      id: antiWasteHero,
      title: 'Pahlawan Anti-Waste',
      description: 'Tandai "tidak ada yang terbuang" 7 hari berturut-turut',
      iconAsset: 'assets/icons/badge_waste.png',
      target: 7,
      progress: 0,
    ),
    Achievement(
      id: smartShopper,
      title: 'Belanja Cerdas',
      description: 'Semua item belanja sudah dicentang',
      iconAsset: 'assets/icons/badge_shopper.png',
      target: 1,
      progress: 0,
    ),
  ];

  static IconData iconFor(String id) {
    switch (id) {
      case firstStep:
        return Icons.flag;
      case streak3:
      case streak7:
        return Icons.local_fire_department;
      case hydrationHero:
        return Icons.water_drop;
      case masterPlanner:
        return Icons.calendar_month;
      case safeWallet:
        return Icons.savings;
      case antiWasteHero:
        return Icons.eco;
      case smartShopper:
        return Icons.shopping_cart_checkout;
      default:
        return Icons.emoji_events;
    }
  }


  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _prevDay(DateTime d) => DateTime(d.year, d.month, d.day - 1);

  static Set<DateTime> activeDays(List<DailyLog> logs) {
    return {
      for (final log in logs)
        if (log.waterMl > 0 ||
            log.mealsEaten.isNotEmpty ||
            log.wasteLogged ||
            log.noWasteMarked)
          _day(log.date),
    };
  }

  static int longestRun(Set<DateTime> days) {
    final sorted = days.map(_day).toSet().toList()..sort();
    int best = 0;
    int run = 0;
    DateTime? previous;
    for (final d in sorted) {
      if (previous != null && _prevDay(d) == previous) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      previous = d;
    }
    return best;
  }


  static int currentStreak(List<DailyLog> logs, DateTime today) {
    final days = activeDays(logs);
    var cursor = _day(today);
    if (!days.contains(cursor)) cursor = _prevDay(cursor);
    int count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = _prevDay(cursor);
    }
    return count;
  }

  static List<Achievement> evaluate({
    required List<DailyLog> logs,
    required int waterTargetMl,
    required List<List<String>> weekPlan,
    required List<Meal> meals,
    required int weeklyBudget,
    required List<GroceryItem> grocery,
  }) {
    final active = activeDays(logs);
    final longestStreak = longestRun(active);

    final hydrationDays = waterTargetMl <= 0
        ? 0
        : logs.where((l) => l.waterMl >= waterTargetMl).length;

    final noWasteRun = longestRun({
      for (final l in logs)
        if (l.noWasteMarked) _day(l.date),
    });

    final fullDays = weekPlan
        .where((day) => day.length >= 3 && day.every((id) => id.isNotEmpty))
        .length;

    final priceById = {for (final m in meals) m.id: m.price};
    final planTotal = weekPlan
        .expand((day) => day)
        .fold<int>(0, (sum, id) => sum + (priceById[id] ?? 0));
    final walletSafe = planTotal > 0 && planTotal <= weeklyBudget;

    final allChecked = grocery.isNotEmpty && grocery.every((g) => g.isChecked);

    return catalog.map((badge) {
      final int raw;
      switch (badge.id) {
        case firstStep:
          raw = active.isEmpty ? 0 : 1;
        case streak3:
        case streak7:
          raw = longestStreak;
        case hydrationHero:
          raw = hydrationDays;
        case masterPlanner:
          raw = fullDays;
        case safeWallet:
          raw = walletSafe ? 1 : 0;
        case antiWasteHero:
          raw = noWasteRun;
        case smartShopper:
          raw = allChecked ? 1 : 0;
        default:
          raw = 0;
      }
      final progress = raw.clamp(0, badge.target).toInt();
      return badge.copyWith(
        progress: progress,
        isUnlocked: progress >= badge.target,
      );
    }).toList();
  }
}