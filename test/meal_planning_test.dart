import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/models/planned_meal.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = {for (final meal in mockMeals) meal.id: meal};
  test('calendar navigation crosses year and leap-day boundaries', () {
    expect(calendarDay(DateTime(2026, 12, 31), 1), DateTime(2027));
    expect(calendarDay(DateTime(2024, 2, 28), 1), DateTime(2024, 2, 29));
    expect(mondayOf(DateTime(2027, 1, 3)), DateTime(2026, 12, 28));
  });

  test('seed assigns real dates and preserves separate eaten status', () {
    final plan = seedMealPlan(DateTime(2026, 11, 4), mockWeekPlan, mockEaten);
    expect(plan, hasLength(21));
    expect(plan.first.scheduledAt, DateTime(2026, 11, 2, 7));
    expect(plan.first.isEaten, mockEaten.first.first);
    expect(plan.map((e) => e.id).toSet(), hasLength(plan.length));
    expect(mealsOnDay(plan, DateTime(2026, 11, 3)), hasLength(3));
  });

  test('portions scale nutrient totals and plan cost', () {
    final meal = mockCookMeals.first;
    final entries = [
      PlannedMeal(
        id: 'a',
        mealId: meal.id,
        scheduledAt: DateTime(2020),
        servings: 1.5,
        isEaten: true,
      ),
    ];
    expect(
      sumNutrient(entries, catalog, Nutrient.calories).value,
      meal.calories * 1.5,
    );
    expect(
      sumNutrient(entries, catalog, Nutrient.protein).value,
      meal.nutrition.proteinGrams * 1.5,
    );
    expect(plannedCost(entries, catalog), (meal.price * 1.5).round());
  });

  test('unknown nutrients and missing meals keep aggregate incomplete', () {
    final known = mockCookMeals.firstWhere(
      (m) => m.nutrition.cholesterolMilligrams != null,
    );
    final unknown = mockBuyMeals.firstWhere(
      (m) => m.nutrition.cholesterolMilligrams == null,
    );
    final entries = [
      PlannedMeal(id: 'a', mealId: known.id, scheduledAt: DateTime(2020)),
      PlannedMeal(id: 'b', mealId: unknown.id, scheduledAt: DateTime(2020)),
      PlannedMeal(id: 'c', mealId: 'missing', scheduledAt: DateTime(2020)),
    ];
    final total = sumNutrient(entries, catalog, Nutrient.cholesterol);
    expect(total.isComplete, isFalse);
    expect(total.known, 1);
    expect(total.count, 3);
    expect(total.value, known.nutrition.cholesterolMilligrams);
    expect(sumNutrient([], catalog, Nutrient.cholesterol).count, 0);
  });

  test(
    'editing a record preserves identity and supports date and portion changes',
    () {
      final original = PlannedMeal(
        id: 'x',
        mealId: 'm1',
        scheduledAt: DateTime(2020),
        isEaten: true,
      );
      final edited = original.copyWith(
        scheduledAt: DateTime(2020, 2),
        servings: 0.5,
        isEaten: false,
      );
      expect(edited.id, original.id);
      expect(edited.isEaten, isFalse);
      expect(original.isEaten, isTrue);
      expect(edited.servings, 0.5);
    },
  );

  test(
    'focus sorting scales portions, restores time order, and keeps data',
    () {
      final day = DateTime(2020);
      final oats = mockCookMeals.first;
      final entries = [
        PlannedMeal(
          id: 'large',
          mealId: oats.id,
          scheduledAt: day,
          servings: 2,
        ),
        PlannedMeal(
          id: 'small',
          mealId: oats.id,
          scheduledAt: DateTime(2020, 1, 1, 12),
          servings: 0.5,
        ),
        PlannedMeal(id: 'unknown', mealId: 'missing', scheduledAt: day),
        PlannedMeal(
          id: 'tie',
          mealId: oats.id,
          scheduledAt: DateTime(2020, 1, 1, 13),
          servings: 0.5,
        ),
      ];
      for (final focus in [NutritionFocus.cholesterol, NutritionFocus.heart]) {
        final sorted = sortPlannedMeals(entries, catalog, focus);
        expect(sorted.map((e) => e.id), ['small', 'tie', 'large', 'unknown']);
        expect(sorted.toSet(), entries.toSet());
        expect(
          sumNutrient(sorted, catalog, Nutrient.calories).value,
          sumNutrient(entries, catalog, Nutrient.calories).value,
        );
      }
      expect(entries.first.id, 'large');
      expect(entries.first.scheduledAt, day);
      expect(
        sortPlannedMeals(
          entries,
          catalog,
          NutritionFocus.general,
        ).map((e) => e.id),
        ['large', 'unknown', 'small', 'tie'],
      );
    },
  );

  test('recipe ingredients support fractions and attached gram units', () {
    final recipe = mockCookMeals.firstWhere((m) => m.id == 'm13');
    final items = recipeGroceries(recipe, 2, 'test');
    expect(items.firstWhere((i) => i.name == 'Tomat').quantity, 1);
    final oats = recipeGroceries(mockCookMeals.first, 1.5, 'oat');
    expect(oats.firstWhere((i) => i.name == 'Oatmeal').quantity, 60);
    expect(oats.firstWhere((i) => i.name == 'Oatmeal').unit, 'g');
    expect(items.every((i) => i.price == 0 && !i.isChecked), isTrue);
    expect(recipeGroceries(mockBuyMeals.first, 1, 'buy'), isEmpty);
  });
}
