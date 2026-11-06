// Owner: Jessica | Recipe, allergy information, and nutrition amounts.

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/planned_meal.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/asset_image.dart';
import 'package:budget_bites/widgets/nutrition_summary.dart';
import 'package:flutter/material.dart';

class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({
    required this.meal,
    this.userAllergies = const [],
    this.onAddToGrocery,
    this.onPlan,
    this.onBack,
    super.key,
  });
  final Meal meal;
  final List<String> userAllergies;
  final void Function(Meal meal, double servings)? onAddToGrocery;
  final void Function(Meal meal, double servings)? onPlan;
  final VoidCallback? onBack;

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  double _servings = 1;

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final theme = Theme.of(context);
    final allergens = meal.allergens.isEmpty
        ? 'Tidak ada'
        : meal.allergens.join(', ');
    final recipe = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (meal.source == MealSource.cook) ...[
          Card(
            child: ExpansionTile(
              initiallyExpanded: true,
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                'Bahan resep • takaran dasar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              children: [
                for (final item in meal.ingredients)
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(item, style: const TextStyle(fontSize: 14)),
                  ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ExpansionTile(
              initiallyExpanded: true,
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                'Cara memasak',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              children: [
                for (var i = 0; i < meal.steps.length; i++)
                  ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      meal.steps[i],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: widget.onAddToGrocery == null
                ? null
                : () => widget.onAddToGrocery!(meal, _servings),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Tambah bahan ke belanja'),
          ),
        ] else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilihan beli siap makan '
                '(Tanyakan bahan, alergen, dan ketersediaan kepada penjual) ',
              ),
            ),
          ),
      ],
    );
    final nutrition = NutritionSummary(
      entries: [
        PlannedMeal(
          id: 'detail',
          mealId: meal.id,
          scheduledAt: DateTime(2000),
          servings: _servings,
        ),
      ],
      meals: [meal],
      goals: const {},
      allNutrients: true,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail menu'),
        leading: BackButton(
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AssetImageWithFallback(
              assetPath: meal.imageAsset,
              height: 220,
              width: double.infinity,
              fallbackIcon: Icons.restaurant,
            ),
          ),
          const SizedBox(height: 20),
          Text(meal.name, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('${meal.source.label} • ${meal.category}'),
          if (meal.source == MealSource.cook)
            Text('Waktu masak contoh: ${meal.cookTimeMinutes} menit'),
          const SizedBox(height: 12),
          Text('Tag diet resep: ${meal.diet?.label ?? 'Belum diberi tag'}'),
          const SizedBox(height: 8),
          Text('Alergen tercatat: $allergens'),
          const SizedBox(height: 4),
          const Text('Daftar alergen contoh tidak menjamin bebas alergen.'),
          if (matchesAllergy(meal, widget.userAllergies))
            Text(
              'Perhatian: terdapat alergen yang cocok dengan profil Anda',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          const SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              const Text('Jumlah porsi'),
              IconButton(
                onPressed: _servings <= 0.5
                    ? null
                    : () => setState(() => _servings -= 0.5),
                tooltip: 'Kurangi porsi',
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                nutrientNumber(_servings),
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                onPressed: _servings >= 10
                    ? null
                    : () => setState(() => _servings += 0.5),
                tooltip: 'Tambah porsi',
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          Text(
            'Takaran dasar: ${meal.nutrition.servingSize} '
            '(${nutrientNumber(meal.nutrition.servingSizeGrams)} g) ',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: widget.onPlan == null
                ? null
                : () => widget.onPlan!(meal, _servings),
            icon: const Icon(Icons.event_available),
            label: const Text('Masukkan rencana'),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (windowSizeFor(constraints.maxWidth) == WindowSize.expanded) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: recipe),
                    const SizedBox(width: 20),
                    Expanded(child: nutrition),
                  ],
                );
              }
              return Column(
                children: [nutrition, const SizedBox(height: 16), recipe],
              );
            },
          ),
        ],
      ),
    );
  }
}
