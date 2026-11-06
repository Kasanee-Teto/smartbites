// Owner: Louis | FR: FR-30, FR-31, FR-35 (hooks: FR-32, FR-33, FR-34)
// Design references:
// - stitch_smartbites_meal_budget_planner/smartbites_modal_catat_cepat_1/code.html
// - stitch_smartbites_meal_budget_planner/smartbites_modal_catat_cepat_2/code.html

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/pantry_item.dart';
import 'package:budget_bites/models/planned_meal.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:flutter/material.dart';

/// Modal Bottom Sheet interaktif "Catat Cepat" untuk mencatat asupan air minum,
/// menandai menu makanan yang selesai disantap, serta mencatat makanan terbuang
/// secara kilat dalam maksimal 2 ketukan (PRD T5, T6, FR-30..35).
class QuickLogSheet extends StatefulWidget {
  const QuickLogSheet({
    required this.dailyWaterTargetMl,
    required this.currentWaterMl,
    required this.todayPlannedMeals,
    required this.mealCatalog,
    required this.onLogWater,
    required this.onMarkMealEaten,
    required this.onLogWaste,
    required this.onNoWaste,
    super.key,
    this.initialTab = 0,
    this.lastWaterMl = 250,
    this.pantryItems = const [],
    this.onOpenWasteForm,
    this.onClose,
  });

  /// Target hidrasi harian pengguna dalam ml.
  final int dailyWaterTargetMl;

  /// Jumlah asupan air minum pengguna hari ini dalam ml.
  final int currentWaterMl;

  /// Indeks tab yang aktif saat modal dibuka (0: Minum, 1: Makan, 2: Waste).
  final int initialTab;

  /// Ukuran asupan air terakhir yang dicatat (default 250 ml).
  final int lastWaterMl;

  /// Daftar jadwal makan hari ini.
  final List<PlannedMeal> todayPlannedMeals;

  /// Katalog menu untuk lookup nama, harga, dan kalori makanan.
  final List<Meal> mealCatalog;

  /// Daftar item bahan dari kulkas/pantry untuk chip catatan cepat food waste.
  final List<PantryItem> pantryItems;

  /// Callback instan saat pengguna mencatat air minum (+ml).
  final ValueChanged<int> onLogWater;

  /// Callback instan saat pengguna menandai menu makan selesai dimakan.
  final ValueChanged<PlannedMeal> onMarkMealEaten;

  /// Callback instan saat pengguna mencatat sisa makanan terbuang.
  final void Function(String itemName, String portion, int estimatedLoss)
  onLogWaste;

  /// Callback instan saat pengguna menandai komitmen bebas sampah ("Nihil").
  final VoidCallback onNoWaste;

  /// Callback untuk membuka form lengkap food waste (navigasi ke tab Air & Waste).
  final VoidCallback? onOpenWasteForm;

  /// Callback untuk menutup modal.
  final VoidCallback? onClose;

  @override
  State<QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends State<QuickLogSheet> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab.clamp(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(35),
                blurRadius: 28,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Drag Handle Pill
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant.withAlpha(160),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull,
                        ),
                      ),
                    ),
                  ),

                  // 2. Sheet Header
                  _buildHeader(context, theme, colorScheme),
                  const SizedBox(height: AppConstants.spaceSm),

                  // 3. Segmented Tab Controls (Minum, Makan, Food Waste)
                  _buildTabSwitcher(context, theme, colorScheme),
                  const SizedBox(height: AppConstants.spaceMd),

                  // 4. Tab Body Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.spaceLg,
                      ),
                      child: switch (_selectedTab) {
                        0 => _buildWaterPane(context, theme, colorScheme),
                        1 => _buildMealPane(context, theme, colorScheme),
                        _ => _buildWastePane(context, theme, colorScheme),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER & TAB CONTROLS
  // ---------------------------------------------------------------------------

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withAlpha(45),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt, color: colorScheme.secondary, size: 22),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '⚡ Catat Cepat',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceXs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryFixed.withAlpha(90),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusSm,
                            ),
                          ),
                          child: Text(
                            'FAST-LOG',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSecondaryFixed,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pencatatan harian cepat ≤ 2 ketukan',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        IconButton.filledTonal(
          onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
          tooltip: 'Tutup',
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainer,
            foregroundColor: colorScheme.onSurfaceVariant,
            minimumSize: const Size(36, 36),
          ),
          icon: const Icon(Icons.close, size: 18),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              iconEmoji: '💧',
              label: 'Minum (+ml)',
              theme: theme,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              index: 1,
              iconEmoji: '🍽️',
              label: 'Makan',
              theme: theme,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              index: 2,
              iconEmoji: '🗑️',
              label: 'Food Waste',
              theme: theme,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String iconEmoji,
    required String label,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _selectedTab == index;

    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(iconEmoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: MINUM (WATER LOGGING)
  // ---------------------------------------------------------------------------

  Widget _buildWaterPane(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final target = widget.dailyWaterTargetMl > 0
        ? widget.dailyWaterTargetMl
        : 2000;
    final percent = ((widget.currentWaterMl / target) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Target Card Banner
        Container(
          padding: const EdgeInsets.all(AppConstants.spaceSm + 2),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withAlpha(50),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMd,
                        ),
                      ),
                      child: Icon(
                        Icons.water_drop,
                        color: colorScheme.tertiary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TARGET HIDRASI HARI INI',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${widget.currentWaterMl}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.tertiary,
                                ),
                              ),
                              Text(
                                ' / $target ml',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceXs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryFixed.withAlpha(90),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  '$percent% Tercapai',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),

        Text(
          'PILIHAN 1-KETUKAN CEPAT',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),

        // 1. +150 ml (Cangkir)
        _buildWaterOptionCard(
          context,
          theme,
          colorScheme,
          amount: 150,
          label: '+150 ml',
          subtitle: 'Cangkir / Kopi Pagi',
          icon: Icons.coffee,
          isLastUsed: widget.lastWaterMl == 150,
        ),
        const SizedBox(height: AppConstants.spaceSm),

        // 2. +250 ml (Gelas) - Highlighted
        _buildWaterOptionCard(
          context,
          theme,
          colorScheme,
          amount: 250,
          label: '+250 ml (Gelas)',
          subtitle: 'Paling sering dicatat anak kos',
          icon: Icons.local_drink,
          isLastUsed: widget.lastWaterMl == 250,
        ),
        const SizedBox(height: AppConstants.spaceSm),

        // 3. +500 ml (Botol)
        _buildWaterOptionCard(
          context,
          theme,
          colorScheme,
          amount: 500,
          label: '+500 ml',
          subtitle: 'Botol minum / Tumbler kos',
          icon: Icons.sports_bar,
          isLastUsed: widget.lastWaterMl == 500,
        ),
      ],
    );
  }

  Widget _buildWaterOptionCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required int amount,
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isLastUsed,
  }) {
    return Card(
      elevation: 0,
      color: isLastUsed
          ? colorScheme.tertiaryContainer.withAlpha(25)
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(
          color: isLastUsed
              ? colorScheme.tertiary.withAlpha(120)
              : colorScheme.outlineVariant.withAlpha(50),
          width: isLastUsed ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () => widget.onLogWater(amount),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isLastUsed
                            ? colorScheme.tertiary
                            : colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSm,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isLastUsed
                            ? colorScheme.onTertiary
                            : colorScheme.tertiary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  label,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isLastUsed) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusSm,
                                    ),
                                  ),
                                  child: Text(
                                    'Terakhir',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            subtitle,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Icon(
                Icons.add_circle,
                color: isLastUsed ? colorScheme.tertiary : colorScheme.primary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: MAKAN (MEAL LOGGING - FR-32)
  // ---------------------------------------------------------------------------

  Widget _buildMealPane(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final completedCount = widget.todayPlannedMeals
        .where((m) => m.isEaten)
        .length;
    final totalCount = widget.todayPlannedMeals.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'JADWAL MAKAN HARI INI',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Text(
              '$completedCount dari $totalCount Selesai',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceSm),

        if (widget.todayPlannedMeals.isEmpty)
          _buildEmptyMealsCard(context, theme, colorScheme)
        else
          ...List.generate(widget.todayPlannedMeals.length, (index) {
            final plannedMeal = widget.todayPlannedMeals[index];
            final meal = widget.mealCatalog
                .where((m) => m.id == plannedMeal.mealId)
                .firstOrNull;
            if (meal == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
              child: _buildMealCard(
                context,
                theme,
                colorScheme,
                plannedMeal: plannedMeal,
                meal: meal,
                slotIndex: index,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildEmptyMealsCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 36,
            color: colorScheme.primary,
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            'Belum ada jadwal menu hari ini',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Rencanakan menu harian di tab Menu & Gizi',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required PlannedMeal plannedMeal,
    required Meal meal,
    required int slotIndex,
  }) {
    final isEaten = plannedMeal.isEaten;
    final slotLabel = switch (slotIndex) {
      0 => 'Sarapan (Pagi)',
      1 => 'Makan Siang (Aktif)',
      _ => 'Makan Malam (Rencana)',
    };

    return Card(
      elevation: 0,
      color: isEaten
          ? colorScheme.surfaceContainerLow.withAlpha(160)
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(
          color: isEaten
              ? Colors.transparent
              : colorScheme.outlineVariant.withAlpha(50),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isEaten
                          ? colorScheme.primary.withAlpha(35)
                          : colorScheme.secondaryContainer.withAlpha(35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEaten ? Icons.check_circle : Icons.restaurant,
                      color: isEaten
                          ? colorScheme.primary
                          : colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slotLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isEaten
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.secondary,
                          ),
                        ),
                        Text(
                          meal.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isEaten
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurface,
                            decoration: isEaten
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${formatRupiah(meal.price)} • ${meal.calories} kkal',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            if (isEaten)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  'Selesai',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              FilledButton.tonalIcon(
                onPressed: () => widget.onMarkMealEaten(plannedMeal),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.done, size: 16),
                label: const Text(
                  'Selesai',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: FOOD WASTE (FR-33 & FR-34)
  // ---------------------------------------------------------------------------

  Widget _buildWastePane(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // 4 staple items for quick logging (matching HTML + Pantry)
    final stapleItems = [
      (name: 'Sayur Bayam', basePrice: 4000),
      (name: 'Susu Kedelai', basePrice: 3500),
      (name: 'Roti Tawar', basePrice: 6000),
      (name: 'Tahu Putih', basePrice: 2500),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Hero Action: Nihil Food Waste Hari Ini (SDG 12.3)
        Card(
          elevation: 0,
          color: colorScheme.primaryContainer.withAlpha(35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            side: BorderSide(
              color: colorScheme.primary.withAlpha(90),
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: widget.onNoWaste,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🌟', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tidak ada makanan terbuang hari ini',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Piring bersih • SDG 12.3 (+1 Streak Hari Ini)',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Icon(Icons.verified, color: colorScheme.primary, size: 22),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),

        Text(
          'ATAU CATAT SISA BAHAN KULKAS (1-KETUKAN):',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),

        // 2. Up to 4 Waste Items with Direct Portion Buttons (2-taps total)
        ...stapleItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
            child: _buildWasteItemRow(
              context,
              theme,
              colorScheme,
              itemName: item.name,
              basePrice: item.basePrice,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceXs),

        // 3. Link ke Form Lengkap Food Waste di Tab Air & Waste (Edbert)
        Center(
          child: TextButton.icon(
            onPressed: widget.onOpenWasteForm,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text(
              'Lainnya: Buka form lengkap catat sampah makanan',
            ),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ),
      ],
    );
  }

  Widget _buildWasteItemRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required String itemName,
    required int basePrice,
  }) {
    final sedikitLoss = (basePrice * 0.25).round();
    final setengahLoss = (basePrice * 0.50).round();
    final semuaLoss = basePrice;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatRupiah(basePrice),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPortionButton(
                theme,
                colorScheme,
                label: 'Sedikit',
                onPressed: () =>
                    widget.onLogWaste(itemName, 'Sedikit', sedikitLoss),
              ),
              const SizedBox(width: 4),
              _buildPortionButton(
                theme,
                colorScheme,
                label: 'Setengah',
                isProminent: true,
                onPressed: () =>
                    widget.onLogWaste(itemName, 'Setengah', setengahLoss),
              ),
              const SizedBox(width: 4),
              _buildPortionButton(
                theme,
                colorScheme,
                label: 'Semua',
                onPressed: () =>
                    widget.onLogWaste(itemName, 'Semua', semuaLoss),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortionButton(
    ThemeData theme,
    ColorScheme colorScheme, {
    required String label,
    required VoidCallback onPressed,
    bool isProminent = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isProminent
              ? colorScheme.secondary.withAlpha(30)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(
            color: isProminent
                ? colorScheme.secondary.withAlpha(120)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: isProminent ? FontWeight.bold : FontWeight.w600,
            fontSize: 10.5,
            color: isProminent
                ? colorScheme.secondary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Menampilkan [QuickLogSheet] melalui Material 3 `showModalBottomSheet`.
Future<void> showQuickLogSheet(
  BuildContext context, {
  required int dailyWaterTargetMl,
  required int currentWaterMl,
  required List<PlannedMeal> todayPlannedMeals,
  required List<Meal> mealCatalog,
  required ValueChanged<int> onLogWater,
  required ValueChanged<PlannedMeal> onMarkMealEaten,
  required void Function(String itemName, String portion, int estimatedLoss)
  onLogWaste,
  required VoidCallback onNoWaste,
  int initialTab = 0,
  int lastWaterMl = 250,
  List<PantryItem> pantryItems = const [],
  VoidCallback? onOpenWasteForm,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => QuickLogSheet(
      dailyWaterTargetMl: dailyWaterTargetMl,
      currentWaterMl: currentWaterMl,
      initialTab: initialTab,
      lastWaterMl: lastWaterMl,
      todayPlannedMeals: todayPlannedMeals,
      mealCatalog: mealCatalog,
      pantryItems: pantryItems,
      onLogWater: (amount) {
        Navigator.of(modalContext).pop();
        onLogWater(amount);
      },
      onMarkMealEaten: (meal) {
        Navigator.of(modalContext).pop();
        onMarkMealEaten(meal);
      },
      onLogWaste: (item, portion, loss) {
        Navigator.of(modalContext).pop();
        onLogWaste(item, portion, loss);
      },
      onNoWaste: () {
        Navigator.of(modalContext).pop();
        onNoWaste();
      },
      onOpenWasteForm: () {
        Navigator.of(modalContext).pop();
        onOpenWasteForm?.call();
      },
      onClose: () => Navigator.of(modalContext).pop(),
    ),
  );
}
