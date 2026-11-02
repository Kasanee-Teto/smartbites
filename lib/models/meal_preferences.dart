// Owner: Jessica, Edbert | Optional meal-search preferences.

import 'package:budget_bites/models/meal.dart';

class MealPreferences {
  const MealPreferences({this.diet, this.maxPrice, this.maxCookMinutes});
  final MealDiet? diet;
  final int? maxPrice;
  final int? maxCookMinutes;

  bool get isActive =>
      diet != null || maxPrice != null || maxCookMinutes != null;

  bool matches(Meal meal) {
    if (diet == MealDiet.vegan && meal.diet != MealDiet.vegan) return false;
    if (diet == MealDiet.vegetarian && meal.diet == null) return false;
    if (maxPrice != null && meal.price > maxPrice!) return false;
    return maxCookMinutes == null || meal.cookTimeMinutes <= maxCookMinutes!;
  }
}

const mealAllergenOptions = [
  'Susu',
  'Telur',
  'Kacang',
  'Kedelai',
  'Gandum',
  'Ikan',
  'Udang',
  'Kepiting',
  'Kerang',
  'Moluska',
  'Wijen',
  'Santan',
  'Bawang',
  'Nanas',
];
