// Owner: Jesseca | FR: FR-08, FR-09, FR-11, FR-12

class Meal {
  const Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.imageAsset,
    required this.price,
    required this.calories,
    required this.cookTimeMinutes,
    required this.ingredients,
    required this.allergens,
    required this.steps,
  });
  final String id;
  final String name;
  final String category;
  final String imageAsset;
  final int price;
  final int calories;
  final int cookTimeMinutes;
  final List<String> ingredients;
  final List<String> allergens;
  final List<String> steps;
}
