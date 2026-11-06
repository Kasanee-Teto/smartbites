import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/meal_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'diet filters require explicit tags and vegan also matches vegetarian',
    () {
      final vegan = mockCookMeals.firstWhere((m) => m.id == 'm20');
      final honeyRecipe = mockCookMeals.firstWhere((m) => m.id == 'm1');
      final unknownStock = mockCookMeals.firstWhere((m) => m.id == 'm5');
      const all = MealPreferences();
      const vegetarian = MealPreferences(diet: MealDiet.vegetarian);
      const plantOnly = MealPreferences(diet: MealDiet.vegan);
      expect(vegetarian.matches(vegan), isTrue);
      expect(plantOnly.matches(vegan), isTrue);
      expect(vegetarian.matches(honeyRecipe), isTrue);
      expect(plantOnly.matches(honeyRecipe), isFalse);
      expect(vegetarian.matches(unknownStock), isFalse);
      expect(plantOnly.matches(mockBuyMeals.first), isFalse);
      expect(all.matches(mockBuyMeals.first), isTrue);
      expect(honeyRecipe.copyWith(price: 1).diet, honeyRecipe.diet);
    },
  );

  test('budget and time limits combine at inclusive boundaries', () {
    final meal = mockCookMeals.first;
    expect(
      MealPreferences(
        maxPrice: meal.price,
        maxCookMinutes: meal.cookTimeMinutes,
      ).matches(meal),
      isTrue,
    );
    expect(MealPreferences(maxPrice: meal.price - 1).matches(meal), isFalse);
    expect(
      MealPreferences(maxCookMinutes: meal.cookTimeMinutes - 1).matches(meal),
      isFalse,
    );
    expect(
      const MealPreferences(maxCookMinutes: 0).matches(mockBuyMeals.first),
      isTrue,
    );
    expect(const MealPreferences(maxPrice: 0).matches(meal), isFalse);
    expect(const MealPreferences().isActive, isFalse);
  });

  test(
    'profile preferences preserve unrelated fields and original fixtures',
    () {
      final updated = mockUserProfile.copyWith(
        allergies: ['Susu'],
        mealPreferences: const MealPreferences(
          diet: MealDiet.vegan,
          maxPrice: 12000,
        ),
      );
      expect(updated.weeklyBudget, mockUserProfile.weeklyBudget);
      expect(updated.waterTargetMl, mockUserProfile.waterTargetMl);
      expect(updated.preferences, mockUserProfile.preferences);
      expect(mockUserProfile.allergies, ['Kacang']);
      expect(mockUserProfile.mealPreferences.diet, isNull);
      expect(updated.mealPreferences.diet, MealDiet.vegan);
    },
  );
}
