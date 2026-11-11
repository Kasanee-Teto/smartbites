import 'package:budget_bites/models/water_record.dart';
import 'package:flutter/material.dart';

extension DrinkCategoryStyle on DrinkCategory {
  IconData get icon => switch (this) {
    DrinkCategory.water => Icons.water_drop_outlined,
    DrinkCategory.coffee => Icons.coffee,
    DrinkCategory.tea => Icons.emoji_food_beverage_outlined,
    DrinkCategory.juice => Icons.local_drink_outlined,
    DrinkCategory.latte => Icons.local_cafe_outlined,
    DrinkCategory.wine => Icons.wine_bar_outlined,
    DrinkCategory.alcohol => Icons.liquor_outlined,
  };

  Color color(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return switch (this) {
      DrinkCategory.water => scheme.tertiary,
      DrinkCategory.coffee =>
        dark ? const Color(0xFFDCAC85) : const Color(0xFF795033),
      DrinkCategory.tea => scheme.primary,
      DrinkCategory.juice =>
        dark ? const Color(0xFFFFBA77) : const Color(0xFF9A4B09),
      DrinkCategory.latte =>
        dark ? const Color(0xFFFFD483) : const Color(0xFF795809),
      DrinkCategory.wine =>
        dark ? const Color(0xFFF4A6C5) : const Color(0xFF9A3B62),
      DrinkCategory.alcohol =>
        dark ? const Color(0xFFC3B1FA) : const Color(0xFF66499A),
    };
  }
}

class DrinkCategoryIcon extends StatelessWidget {
  const DrinkCategoryIcon({required this.category, super.key});

  final DrinkCategory category;

  @override
  Widget build(BuildContext context) {
    final color = category.color(Theme.of(context).colorScheme);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Icon(category.icon, color: color, size: 20),
      ),
    );
  }
}
