// Owner: Edbert | FR: FR-22, FR-23

enum DrinkCategory {
  water('Air putih', 250, 100),
  coffee('Kopi', 150, 80),
  tea('Teh', 200, 100),
  juice('Jus', 200, 100),
  latte('Latte', 250, 80),
  wine('Wine', 150, -50),
  alcohol('Alkohol', 50, -50);

  DrinkCategory(this.label, this.defaultMl, this.creditPercent);

  final String label;
  final int defaultMl;
  final int creditPercent;
}

class WaterRecord {
  const WaterRecord({
    required this.id,
    required this.amountMl,
    required this.time,
    this.category = DrinkCategory.water,
  });
  final String id;
  final int amountMl;
  final DateTime time;
  final DrinkCategory category;

  double get hydrationMl => amountMl * category.creditPercent / 100;
}
