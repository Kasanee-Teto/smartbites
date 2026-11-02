// Owner: Jessica | Date-based meal planning and food diary.

class PlannedMeal {
  const PlannedMeal({
    required this.id,
    required this.mealId,
    required this.scheduledAt,
    this.servings = 1,
    this.isEaten = false,
  });

  final String id;
  final String mealId;
  final DateTime scheduledAt;
  final double servings;
  final bool isEaten;

  PlannedMeal copyWith({
    String? mealId,
    DateTime? scheduledAt,
    double? servings,
    bool? isEaten,
  }) {
    return PlannedMeal(
      id: id,
      mealId: mealId ?? this.mealId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      servings: servings ?? this.servings,
      isEaten: isEaten ?? this.isEaten,
    );
  }
}
