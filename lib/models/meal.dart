// Owner: Jessica | FR: FR-08, FR-09, FR-11, FR-12

import 'package:budget_bites/models/nutrition_facts.dart';

enum MealSource {
  cook('Masak Sendiri'),
  buy('Beli Siap Makan');

  MealSource(this.label);
  final String label;
}

enum MealDiet {
  vegetarian('Vegetarian'),
  vegan('Vegan');

  MealDiet(this.label);
  final String label;
}

class Meal {
  const Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.imageAsset,
    required this.price,
    required this.calories,
    required this.nutrition,
    required this.cookTimeMinutes,
    required this.ingredients,
    required this.allergens,
    required this.steps,
    this.diet,
  }) : source = MealSource.cook;

  const Meal.buy({
    required this.id,
    required this.name,
    required this.category,
    required this.imageAsset,
    required this.price,
    required this.calories,
    required this.nutrition,
    required this.allergens,
    this.diet,
  }) : source = MealSource.buy,
       cookTimeMinutes = 0,
       ingredients = const [],
       steps = const [];

  final String id;
  final String name;
  final String category;
  final String imageAsset;
  final int price;
  final int calories;
  final NutritionFacts nutrition;
  final int cookTimeMinutes;
  final List<String> ingredients;
  final List<String> allergens;
  final List<String> steps;
  final MealSource source;
  // Null means untagged; it must not be inferred from the dish name.
  final MealDiet? diet;

  Meal copyWith({
    String? id,
    String? name,
    String? category,
    String? imageAsset,
    int? price,
    int? calories,
    NutritionFacts? nutrition,
    int? cookTimeMinutes,
    List<String>? ingredients,
    List<String>? allergens,
    List<String>? steps,
    MealDiet? diet,
  }) {
    if (source == MealSource.buy) {
      return Meal.buy(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        imageAsset: imageAsset ?? this.imageAsset,
        price: price ?? this.price,
        calories: calories ?? this.calories,
        nutrition: nutrition ?? this.nutrition,
        allergens: allergens ?? this.allergens,
        diet: diet ?? this.diet,
      );
    }

    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageAsset: imageAsset ?? this.imageAsset,
      price: price ?? this.price,
      calories: calories ?? this.calories,
      nutrition: nutrition ?? this.nutrition,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      steps: steps ?? this.steps,
      diet: diet ?? this.diet,
    );
  }
}
