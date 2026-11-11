// Owner: Jessica | Meal catalog, plan, and diary cards.

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/utils/meal_planning.dart';
import 'package:budget_bites/widgets/asset_image.dart';
import 'package:budget_bites/widgets/list_tile_spacing.dart';
import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    required this.meal,
    this.servings = 1,
    this.time,
    this.isEaten,
    this.hasAllergy = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSelect,
    this.onEatenChanged,
    super.key,
  });
  final Meal meal;
  final double servings;
  final String? time;
  final bool? isEaten;
  final bool hasAllergy;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSelect;
  final ValueChanged<bool>? onEatenChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final protein = nutrientNumber(meal.nutrition.proteinGrams * servings);
    final carbs = nutrientNumber(meal.nutrition.carbohydrateGrams * servings);
    final fat = nutrientNumber(meal.nutrition.totalFatGrams * servings);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: AssetImageWithFallback(
                          assetPath: meal.imageAsset,
                          width: 72,
                          height: 80,
                          fallbackIcon: Icons.restaurant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (time != null)
                              Text(
                                '$time • ${nutrientNumber(servings)} porsi',
                                style: theme.textTheme.labelMedium,
                              ),
                            Text(meal.name, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              meal.source.label,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onEdit != null || onDelete != null)
                        PopupMenuButton<String>(
                          tooltip: 'Tindakan menu',
                          onSelected: (action) {
                            if (action == 'edit') onEdit?.call();
                            if (action == 'delete') onDelete?.call();
                          },
                          itemBuilder: (_) => [
                            if (onEdit != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Ubah jadwal'),
                              ),
                            if (onDelete != null)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus menu'),
                              ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Text(
                        formatRupiah((meal.price * servings).round()),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text('${(meal.calories * servings).round()} kkal'),
                      Text(
                        meal.source == MealSource.cook
                            ? '${meal.cookTimeMinutes} menit masak'
                            : 'Siap makan',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Protein $protein g • Karbo $carbs g • Lemak $fat g',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (meal.diet != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Tag resep: ${meal.diet!.label}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (hasAllergy) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Mengandung alergen profil Anda',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isEaten != null)
            ListTileSpacing(
              child: CheckboxListTile(
                title: Text(isEaten! ? 'Sudah dimakan' : 'Tandai dimakan'),
                value: isEaten,
                onChanged: onEatenChanged == null
                    ? null
                    : (value) => onEatenChanged!(value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          if (onSelect != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  TextButton(
                    onPressed: onTap,
                    child: const Text('Lihat detail'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: onSelect,
                    icon: const Icon(Icons.add),
                    label: const Text('Pilih menu'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
