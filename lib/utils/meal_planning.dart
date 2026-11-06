// Owner: Jessica | Shared calculations for planner, diary, and nutrition.

import 'package:budget_bites/models/grocery_item.dart';
import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/planned_meal.dart';

enum NutritionFocus {
  general('Umum'),
  cholesterol('Kolesterol'),
  heart('Jantung');

  NutritionFocus(this.label);
  final String label;
}

enum Nutrient {
  calories('Kalori', 'kkal'),
  protein('Protein', 'g'),
  carbs('Karbohidrat', 'g'),
  fat('Lemak total', 'g', isLimit: true),
  saturatedFat('Lemak jenuh', 'g', isLimit: true),
  transFat('Lemak trans', 'g', isLimit: true),
  fiber('Serat', 'g'),
  sugar('Gula total', 'g', isLimit: true),
  addedSugar('Gula tambahan', 'g', isLimit: true),
  sodium('Natrium', 'mg', isLimit: true),
  cholesterol('Kolesterol', 'mg', isLimit: true),
  vitaminD('Vitamin D', 'mcg'),
  calcium('Kalsium', 'mg'),
  iron('Zat besi', 'mg'),
  potassium('Kalium', 'mg');

  Nutrient(this.label, this.unit, {this.isLimit = false});
  final String label;
  final String unit;
  final bool isLimit;

  double? amount(Meal meal) {
    final n = meal.nutrition;
    return switch (this) {
      calories => meal.calories.toDouble(),
      protein => n.proteinGrams,
      carbs => n.carbohydrateGrams,
      fat => n.totalFatGrams,
      saturatedFat => n.saturatedFatGrams,
      transFat => n.transFatGrams,
      fiber => n.fiberGrams,
      sugar => n.totalSugarsGrams,
      addedSugar => n.addedSugarsGrams,
      sodium => n.sodiumMilligrams,
      cholesterol => n.cholesterolMilligrams,
      vitaminD => n.vitaminDMicrograms,
      calcium => n.calciumMilligrams,
      iron => n.ironMilligrams,
      potassium => n.potassiumMilligrams,
    };
  }
}

class NutrientTotal {
  const NutrientTotal(this.value, this.known, this.count);
  final double value;
  final int known;
  final int count;
  bool get isComplete => known == count;
}

DateTime calendarDay(DateTime date, [int offset = 0]) =>
    DateTime(date.year, date.month, date.day + offset);

DateTime mondayOf(DateTime date) => calendarDay(date, 1 - date.weekday);

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const shortDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String mealDateLabel(DateTime date) =>
    '${date.day} ${monthNames[date.month - 1]} ${date.year}';

String mealTimeLabel(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}.'
    '${date.minute.toString().padLeft(2, '0')}';

String nutrientNumber(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1).replaceAll('.', ',');

List<PlannedMeal> seedMealPlan(
  DateTime today,
  List<List<String>> week,
  List<List<bool>> eaten,
) {
  final monday = mondayOf(today);
  const hours = [7, 12, 19];
  return [
    for (var day = 0; day < week.length; day++)
      for (var slot = 0; slot < week[day].length && slot < 3; slot++)
        PlannedMeal(
          id: 'seed_${day}_$slot',
          mealId: week[day][slot],
          scheduledAt: DateTime(
            monday.year,
            monday.month,
            monday.day + day,
            hours[slot],
          ),
          isEaten:
              day < eaten.length &&
              slot < eaten[day].length &&
              eaten[day][slot],
        ),
  ];
}

List<PlannedMeal> mealsOnDay(List<PlannedMeal> entries, DateTime day) =>
    entries.where((e) => sameDay(e.scheduledAt, day)).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

List<PlannedMeal> sortPlannedMeals(
  Iterable<PlannedMeal> entries,
  Map<String, Meal> catalog,
  NutritionFocus focus,
) {
  final nutrient = switch (focus) {
    NutritionFocus.general => null,
    NutritionFocus.cholesterol => Nutrient.saturatedFat,
    NutritionFocus.heart => Nutrient.sodium,
  };
  return entries.toList()..sort((a, b) {
    if (nutrient != null) {
      final mealA = catalog[a.mealId];
      final mealB = catalog[b.mealId];
      final amountA = mealA == null ? null : nutrient.amount(mealA);
      final amountB = mealB == null ? null : nutrient.amount(mealB);
      if (amountA == null && amountB != null) return 1;
      if (amountA != null && amountB == null) return -1;
      if (amountA != null && amountB != null) {
        final comparison = (amountA * a.servings).compareTo(
          amountB * b.servings,
        );
        if (comparison != 0) return comparison;
      }
    }
    final time = a.scheduledAt.compareTo(b.scheduledAt);
    return time != 0 ? time : a.id.compareTo(b.id);
  });
}

NutrientTotal sumNutrient(
  Iterable<PlannedMeal> entries,
  Map<String, Meal> catalog,
  Nutrient nutrient,
) {
  var value = 0.0;
  var known = 0;
  var count = 0;
  for (final entry in entries) {
    count++;
    final meal = catalog[entry.mealId];
    final amount = meal == null ? null : nutrient.amount(meal);
    if (amount != null) {
      known++;
      value += amount * entry.servings;
    }
  }
  return NutrientTotal(value, known, count);
}

int plannedCost(Iterable<PlannedMeal> entries, Map<String, Meal> catalog) =>
    entries
        .fold<double>(
          0,
          (sum, e) => sum + (catalog[e.mealId]?.price ?? 0) * e.servings,
        )
        .round();

bool matchesAllergy(Meal meal, List<String> allergies) => meal.allergens.any(
  (tag) => allergies.any((a) => a.toLowerCase() == tag.toLowerCase()),
);

List<Nutrient> focusNutrients(NutritionFocus focus) => switch (focus) {
  NutritionFocus.general => [
    Nutrient.calories,
    Nutrient.protein,
    Nutrient.carbs,
    Nutrient.fat,
    Nutrient.fiber,
    Nutrient.sugar,
  ],
  NutritionFocus.cholesterol => [
    Nutrient.saturatedFat,
    Nutrient.cholesterol,
    Nutrient.transFat,
    Nutrient.fiber,
    Nutrient.sodium,
  ],
  NutritionFocus.heart => [
    Nutrient.sodium,
    Nutrient.saturatedFat,
    Nutrient.fiber,
    Nutrient.cholesterol,
    Nutrient.potassium,
  ],
};

List<GroceryItem> recipeGroceries(Meal meal, double servings, String prefix) {
  if (meal.source != MealSource.cook) return [];
  final result = <GroceryItem>[];
  final pattern = RegExp(r'^(.*?)\s+(\d+(?:[.,]\d+)?(?:/\d+)?)\s*(.*)$');
  for (var i = 0; i < meal.ingredients.length; i++) {
    final text = meal.ingredients[i];
    final match = pattern.firstMatch(text);
    final name = match?.group(1) ?? text;
    if (name.toLowerCase() == 'air') continue;
    final quantityText = match?.group(2) ?? '1';
    final parts = quantityText.split('/');
    var quantity = double.parse(parts.first.replaceAll(',', '.'));
    if (parts.length == 2) quantity /= double.parse(parts[1]);
    final unit = match?.group(3)?.trim();
    result.add(
      GroceryItem(
        id: '${prefix}_$i',
        name: name,
        quantity: quantity * servings,
        unit: unit == null || unit.isEmpty ? 'porsi' : unit,
        price: 0,
      ),
    );
  }
  return result;
}
