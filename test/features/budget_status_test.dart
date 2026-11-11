// Owner: Louis | Tests: BudgetStatus, budgetStatus pure function, weeklyTotal, and badge helpers

import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/models/planned_meal.dart';
import 'package:budget_bites/utils/budget_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('budgetStatus pure function tests', () {
    test(
      'returns belumDiatur when budget is 0 or negative (edge case: budget 0)',
      () {
        expect(budgetStatus(0, 0), BudgetStatus.belumDiatur);
        expect(budgetStatus(50000, 0), BudgetStatus.belumDiatur);
        expect(budgetStatus(50000, -100000), BudgetStatus.belumDiatur);
      },
    );

    test(
      'clamps negative spent to 0 and evaluates against positive budget',
      () {
        expect(budgetStatus(-25000, 100000), BudgetStatus.hemat);
        expect(budgetStatus(-1, 300000), BudgetStatus.hemat);
      },
    );

    test('evaluates spent 0 as hemat', () {
      expect(budgetStatus(0, 300000), BudgetStatus.hemat);
    });

    test('evaluates 90 percent boundary correctly (up to 90% is hemat, above 90% is pas)', () {
      // 89% -> hemat
      expect(budgetStatus(89, 100), BudgetStatus.hemat);
      expect(budgetStatus(269999, 300000), BudgetStatus.hemat);

      // Exactly 90% -> hemat (Up to 90 percent is hemat)
      expect(budgetStatus(90, 100), BudgetStatus.hemat);
      expect(budgetStatus(270000, 300000), BudgetStatus.hemat);

      // 91% -> pas (90 to 100 is pas)
      expect(budgetStatus(91, 100), BudgetStatus.pas);
      expect(budgetStatus(270001, 300000), BudgetStatus.pas);
    });

    test('evaluates 100 percent boundary correctly (up to 100% is pas, above 100% is melebihi)', () {
      // 95% -> pas
      expect(budgetStatus(95, 100), BudgetStatus.pas);

      // Exactly 100% -> pas
      expect(budgetStatus(100, 100), BudgetStatus.pas);
      expect(budgetStatus(300000, 300000), BudgetStatus.pas);

      // 101% -> melebihi (above 100 is melebihi)
      expect(budgetStatus(101, 100), BudgetStatus.melebihi);
      expect(budgetStatus(300001, 300000), BudgetStatus.melebihi);
      expect(budgetStatus(450000, 300000), BudgetStatus.melebihi);
    });
  });

  group('weeklyTotal pure function tests (Task 1, 5, 6)', () {
    final mealA = mockCookMeals[0]; // Oatmeal (price 8000)
    final mealB = mockCookMeals[1]; // Sayur Bening Bayam Jagung (price 10000)

    // Edge case: empty plan
    test('returns 0 when weekPlan or meals list is empty', () {
      expect(weeklyTotal([], [mealA]), 0);
      expect(weeklyTotal(null, [mealA]), 0);
      expect(
        weeklyTotal([
          [mealA.id],
        ], []),
        0,
      );
      expect(weeklyTotal(<List<String>>[[], [], []], [mealA, mealB]), 0);
    });

    // Partial plan
    test('calculates correct total for partial weekPlan', () {
      final partialPlan = [
        [mealA.id],
      ];
      expect(weeklyTotal(partialPlan, [mealA, mealB]), mealA.price);

      final multiDayPartial = [
        [mealA.id, mealB.id],
        [mealA.id],
      ];
      expect(
        weeklyTotal(multiDayPartial, [mealA, mealB]),
        (mealA.price * 2) + mealB.price,
      );
    });

    // Full plan (7 days x 3 slots = 21 meals)
    test('calculates correct total for full 21-slot weekPlan', () {
      final total = weeklyTotal(mockWeekPlan, mockMeals);
      expect(total, greaterThan(0));

      // Calculate manual expectation
      final priceMap = {for (final m in mockMeals) m.id: m.price};
      var expectedSum = 0;
      for (final day in mockWeekPlan) {
        for (final id in day) {
          expectedSum += priceMap[id] ?? 0;
        }
      }
      expect(total, expectedSum);
    });

    // Edge case: unknown meal id
    test('ignores missing meal IDs gracefully without crashing', () {
      final weekPlanWithUnknown = [
        [mealA.id, 'unknown_id', 'missing_meal_999'],
        ['another_unknown'],
      ];
      expect(weeklyTotal(weekPlanWithUnknown, [mealA]), mealA.price);
    });

    // Edge case: price 0 and negative price
    test('handles price 0 and negative prices safely', () {
      final freeMeal = mealA.copyWith(
        id: 'free_meal',
        name: 'Air Putih Hangat',
        price: 0,
      );
      final negativePriceMeal = mealA.copyWith(
        id: 'negative_meal',
        name: 'Diskon Abnormal',
        price: -5000,
      );

      final plan = [
        [mealA.id, freeMeal.id, negativePriceMeal.id],
      ];
      // mealA is 8000, freeMeal is 0, negativePriceMeal clamped to 0 -> total 8000
      expect(
        weeklyTotal(plan, [mealA, freeMeal, negativePriceMeal]),
        mealA.price,
      );
    });

    // Support Iterable<PlannedMeal>
    test('supports Iterable<PlannedMeal> entries with servings scaling', () {
      final entries = [
        PlannedMeal(
          id: 'p1',
          mealId: mealA.id,
          scheduledAt: DateTime.now(),
          servings: 1.5,
        ),
        PlannedMeal(
          id: 'p2',
          mealId: mealB.id,
          scheduledAt: DateTime.now(),
          servings: 2,
        ),
      ];

      final total = weeklyTotal(entries, [mealA, mealB]);
      // mealA is 8000 * 1.5 = 12000, mealB is 15000 * 2 = 30000 -> 42000
      expect(total, 42000);
    });
  });

  group('Badge contract helpers (Dompet Aman & Perencana Handal - Task 4)', () {
    test(
      'isMealPlanFull checks if all 7 days have at least 3 meal slots filled',
      () {
        // Full 7 days x 3 slots
        expect(isMealPlanFull(mockWeekPlan), isTrue);

        // Incomplete: only 6 days
        final sixDaysPlan = mockWeekPlan.take(6).toList();
        expect(isMealPlanFull(sixDaysPlan), isFalse);

        // Incomplete: 7 days but one day has only 2 meals
        final partialSlotsPlan = [
          ...mockWeekPlan.take(6),
          ['m1', 'm2'], // only 2 slots
        ];
        expect(isMealPlanFull(partialSlotsPlan), isFalse);

        // Incomplete: empty slot string
        final emptySlotPlan = [
          ...mockWeekPlan.take(6),
          ['m1', '', 'm3'],
        ];
        expect(isMealPlanFull(emptySlotPlan), isFalse);
      },
    );

    test('isBudgetSafe verifies planTotal within positive weekly budget', () {
      // Safe within budget
      expect(isBudgetSafe(200000, 300000), isTrue);
      // Exactly on budget
      expect(isBudgetSafe(300000, 300000), isTrue);
      // Over budget
      expect(isBudgetSafe(350000, 300000), isFalse);
      // Budget not set (0)
      expect(isBudgetSafe(200000, 0), isFalse);
      // Plan total 0 (no planned meals)
      expect(isBudgetSafe(0, 300000), isFalse);
    });
  });
}
