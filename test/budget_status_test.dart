// Owner: Louis | Tests: BudgetStatus, budgetStatus pure function, weeklyTotal

import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/utils/budget_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('budgetStatus pure function tests', () {
    test('returns belumDiatur when budget is 0 or negative', () {
      expect(budgetStatus(0, 0), BudgetStatus.belumDiatur);
      expect(budgetStatus(50000, 0), BudgetStatus.belumDiatur);
      expect(budgetStatus(50000, -100000), BudgetStatus.belumDiatur);
    });

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

  group('weeklyTotal pure function tests', () {
    final mealA = mockCookMeals[0]; // Oatmeal (price 8000)
    final mealB = mockCookMeals[1]; // Sayur Bening Bayam Jagung (price 10000)

    test('calculates correct total from weekPlan and meal catalog', () {
      final weekPlan = [
        [mealA.id, mealB.id],
        [mealA.id],
      ];

      final total = weeklyTotal(weekPlan, [mealA, mealB]);
      expect(total, (mealA.price * 2) + mealB.price);
    });

    test('returns 0 when weekPlan or meals list is empty', () {
      expect(weeklyTotal([], [mealA]), 0);
      expect(
        weeklyTotal([
          [mealA.id],
        ], []),
        0,
      );
    });

    test('ignores missing meal IDs gracefully without crashing', () {
      final weekPlan = [
        [mealA.id, 'unknown_id'],
      ];
      expect(weeklyTotal(weekPlan, [mealA]), mealA.price);
    });
  });
}
