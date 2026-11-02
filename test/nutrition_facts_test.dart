import 'package:budget_bites/data/mock_data.dart';
import 'package:budget_bites/models/nutrition_facts.dart';
import 'package:flutter_test/flutter_test.dart';

NutritionFacts _facts({
  double? addedSugarsGrams,
  double? transFatGrams,
  double? vitaminDMicrograms,
}) {
  return NutritionFacts(
    servingSize: '1 porsi',
    servingSizeGrams: 250,
    totalFatGrams: 10,
    saturatedFatGrams: 2,
    sodiumMilligrams: 300,
    carbohydrateGrams: 30,
    fiberGrams: 3,
    totalSugarsGrams: 5,
    proteinGrams: 12,
    addedSugarsGrams: addedSugarsGrams,
    transFatGrams: transFatGrams,
    vitaminDMicrograms: vitaminDMicrograms,
  );
}

void main() {
  test('unknown nutrient values remain distinct from a stated zero', () {
    final unknown = _facts();
    final zero = _facts(transFatGrams: 0, vitaminDMicrograms: 0);
    expect(unknown.transFatGrams, isNull);
    expect(unknown.vitaminDMicrograms, isNull);
    expect(unknown.addedSugarsGrams, isNull);
    expect(zero.transFatGrams, 0);
    expect(zero.vitaminDMicrograms, 0);
    expect(unknown.isEstimate, isTrue);
  });

  test('sample servings have positive finite weights', () {
    for (final meal in mockMeals) {
      expect(meal.nutrition.servingSizeGrams.isFinite, isTrue);
      expect(meal.nutrition.servingSizeGrams, greaterThan(0));
    }
  });

  test('known sample nutrient amounts are nonnegative and finite', () {
    for (final meal in mockMeals) {
      final facts = meal.nutrition;
      final amounts = [
        facts.totalFatGrams,
        facts.saturatedFatGrams,
        facts.sodiumMilligrams,
        facts.carbohydrateGrams,
        facts.fiberGrams,
        facts.totalSugarsGrams,
        facts.proteinGrams,
        facts.transFatGrams,
        facts.cholesterolMilligrams,
        facts.addedSugarsGrams,
        facts.vitaminDMicrograms,
        facts.calciumMilligrams,
        facts.ironMilligrams,
        facts.potassiumMilligrams,
      ];
      for (final value in amounts.nonNulls) {
        expect(value.isFinite, isTrue, reason: meal.name);
        expect(value, greaterThanOrEqualTo(0), reason: meal.name);
      }
    }
  });

  test('sample fat components fit the total fat amount', () {
    for (final meal in mockMeals) {
      final facts = meal.nutrition;
      expect(
        facts.saturatedFatGrams + (facts.transFatGrams ?? 0),
        lessThanOrEqualTo(facts.totalFatGrams),
        reason: meal.name,
      );
    }
  });

  test('sample sugars and fiber fit their parent nutrient amounts', () {
    for (final meal in mockMeals) {
      final facts = meal.nutrition;
      expect(
        facts.fiberGrams + facts.totalSugarsGrams,
        lessThanOrEqualTo(facts.carbohydrateGrams),
        reason: meal.name,
      );
      if (facts.addedSugarsGrams case final addedSugar?) {
        expect(addedSugar, lessThanOrEqualTo(facts.totalSugarsGrams));
      }
    }
  });
}
