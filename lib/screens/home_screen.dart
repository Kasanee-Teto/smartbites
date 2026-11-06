// Owner: Louis | FR: FR-04, FR-05, FR-06, FR-36
// Design: stitch_smartbites_meal_budget_planner/smartbites_beranda/code.html

import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/user_profile.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/utils/streak_logic.dart';
import 'package:budget_bites/widgets/budget_card.dart';
import 'package:budget_bites/widgets/streak_card.dart';
import 'package:flutter/material.dart';

/// Layar utama (Beranda) SmartBites yang menampilkan ringkasan anggaran mingguan,
/// gamifikasi streak, pencatatan hidrasi 1-ketuk, menu hari ini, dan aksi bebas sampah.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.profile,
    super.key,
    this.userName = 'Rani',
    this.userBio = '20 thn • Mahasiswa Kost Aktif',
    this.todayMeals = const [],
    this.todayEaten = const [],
    this.totalWeeklyBudget = 300000,
    this.currentSpent = 0,
    this.todayWaterMl = 0,
    this.streakDays = 0,
    this.streakLevelValue,
    this.nextTarget,
    this.streakProgress,
    this.isLoggedToday = true,
    this.onQuickWaterAdd,
    this.onLogWater,
    this.onToggleMealEaten,
    this.onOpenMealPlan,
    this.onGoToTab,
    this.onOpenInsight,
    this.onOpenStreak,
    this.onNoWaste,
  });

  /// Profil pengguna saat ini.
  final UserProfile profile;

  /// Nama tampilan pengguna (default 'Rani' sesuai desain HTML Beranda).
  final String userName;

  /// Keterangan profil singkat (default '20 thn • Mahasiswa Kost Aktif').
  final String userBio;

  /// Daftar menu makanan yang dijadwalkan untuk hari ini.
  final List<Meal> todayMeals;

  /// Status apakah masing-masing menu hari ini sudah dimakan.
  final List<bool> todayEaten;

  /// Batas total anggaran makan mingguan dalam Rupiah.
  final int totalWeeklyBudget;

  /// Total pengeluaran yang telah dicatat atau direncanakan minggu ini.
  final int currentSpent;

  /// Jumlah asupan air minum hari ini dalam mililiter (ml).
  final int todayWaterMl;

  /// Jumlah hari beruntun kebiasaan aktif (streak).
  final int streakDays;

  /// Tingkat level gamifikasi streak (opsional; dihitung otomatis jika null).
  final int? streakLevelValue;

  /// Target badge streak berikutnya (opsional; dihitung otomatis jika null).
  final int? nextTarget;

  /// Progres saat ini menuju [nextTarget] (opsional; dihitung otomatis jika null).
  final int? streakProgress;

  /// Apakah pengguna sudah mencatat aktivitas hari ini (default true).
  final bool isLoggedToday;

  /// Callback cepat penambahan asupan air minum (kompatibilitas kontrak).
  final ValueChanged<int>? onQuickWaterAdd;

  /// Callback penambahan asupan air minum (alias untuk onQuickWaterAdd).
  final ValueChanged<int>? onLogWater;

  /// Callback toggle status makan untuk slot menu tertentu.
  // ignore: avoid_positional_boolean_parameters
  final void Function(int slotIndex, bool eaten)? onToggleMealEaten;

  /// Callback untuk berpindah ke tab Perencana Makan.
  final VoidCallback? onOpenMealPlan;

  /// Callback fleksibel untuk berpindah ke indeks tab tertentu.
  final ValueChanged<int>? onGoToTab;

  /// Callback untuk membuka layar Insight Nutrisi & Hemat.
  final VoidCallback? onOpenInsight;

  /// Callback untuk membuka detail streak / pencapaian (Profil).
  final VoidCallback? onOpenStreak;

  /// Callback saat pengguna menandai komitmen bebas sampah hari ini ("Habis Semua!").
  final VoidCallback? onNoWaste;

  void _addWater(int amount) {
    (onLogWater ?? onQuickWaterAdd)?.call(amount);
  }

  void _navigateToMealPlan() {
    if (onOpenMealPlan != null) {
      onOpenMealPlan!();
    } else {
      onGoToTab?.call(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final windowSize = windowSizeFor(constraints.maxWidth);
            final isCompact = windowSize == WindowSize.compact;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxContentWidth,
                ),
                child: isCompact
                    ? _buildCompactLayout(context, theme, colorScheme)
                    : _buildWideLayout(context, theme, colorScheme),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LAYOUT VARIANTS
  // ---------------------------------------------------------------------------

  /// Layout vertikal 1 kolom untuk ukuran Compact (Ponsel).
  Widget _buildCompactLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceMd,
      ),
      children: [
        _buildGreetingHeader(context, theme, colorScheme),
        const SizedBox(height: AppConstants.spaceMd),
        _buildBudgetCard(context),
        const SizedBox(height: AppConstants.spaceMd),
        _buildStreakCard(context, theme, colorScheme),
        const SizedBox(height: AppConstants.spaceMd),
        _buildWaterCard(context, theme, colorScheme),
        const SizedBox(height: AppConstants.spaceLg),
        _buildTodayMenuSection(context, theme, colorScheme),
        const SizedBox(height: AppConstants.spaceMd),
        _buildZeroWasteCard(context, theme, colorScheme),
        // Jarak aman agar FloatingActionButton 'Catat Cepat' tidak menutupi kartu
        const SizedBox(height: 104),
      ],
    );
  }

  /// Layout 2 kolom untuk ukuran Medium dan Expanded (Tablet / Desktop).
  Widget _buildWideLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGreetingHeader(context, theme, colorScheme),
          const SizedBox(height: AppConstants.spaceLg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Kiri: Budget, Streak, Water Progress
              Expanded(
                child: Column(
                  children: [
                    _buildBudgetCard(context),
                    const SizedBox(height: AppConstants.spaceMd),
                    _buildStreakCard(context, theme, colorScheme),
                    const SizedBox(height: AppConstants.spaceMd),
                    _buildWaterCard(context, theme, colorScheme),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceLg),
              // Kolom Kanan: Menu Hari Ini & Zero Waste Commitment
              Expanded(
                child: Column(
                  children: [
                    _buildTodayMenuSection(context, theme, colorScheme),
                    const SizedBox(height: AppConstants.spaceMd),
                    _buildZeroWasteCard(context, theme, colorScheme),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 104),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 1: GREETING & DAILY INSIGHT HEADER
  // ---------------------------------------------------------------------------

  Widget _buildGreetingHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final displayName = userName.trim().isNotEmpty
        ? userName.trim()
        : 'Teman SmartBites';
    final subtitleText = userBio.trim().isNotEmpty
        ? userBio.trim()
        : 'Pola Hidup Sehat & Hemat';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Baris Header: Salam + Tombol Insight
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $displayName! 👋',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            IconButton.filledTonal(
              onPressed: onOpenInsight,
              tooltip: 'Lihat Insight Nutrisi & Hemat',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHigh,
                foregroundColor: colorScheme.primary,
                minimumSize: const Size(44, 44),
              ),
              icon: const Icon(Icons.tips_and_updates_outlined),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceSm),

        // Compact Inspirational Daily Micro-Banner (HTML line 35-41)
        InkWell(
          onTap: onOpenInsight,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.spa_outlined,
                  size: 20,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    'Pilihan Bijak Hari Ini: Sayur segar lebih hemat 35% di pasar pagi!',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceXs),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 2: BUDGET CARD (WEEKLY SUMMARY)
  // ---------------------------------------------------------------------------

  Widget _buildBudgetCard(BuildContext context) {
    return BudgetCard(
      spent: currentSpent,
      budget: totalWeeklyBudget,
      onTap: onOpenInsight,
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 3: STREAK CARD (GAMIFICATION)
  // ---------------------------------------------------------------------------

  Widget _buildStreakCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final level = streakLevelValue ?? streakLevel(streakDays);
    final badgeProgress = nextBadgeProgress(streakDays);

    return StreakCard(
      streak: streakDays,
      level: level,
      nextTarget: nextTarget ?? badgeProgress.target,
      progress: streakProgress ?? badgeProgress.progress,
      isLoggedToday: isLoggedToday,
      onTap: onOpenStreak ?? () => onGoToTab?.call(4),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 4: WATER PROGRESS CARD (ONE-TAP LOGGING)
  // ---------------------------------------------------------------------------

  Widget _buildWaterCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // TODO(Edbert): Step 7 WaterProgressCard - Integrasi penuh dengan pelacak hidrasi harian.
    final target = profile.waterTargetMl > 0 ? profile.waterTargetMl : 2000;
    final ratio = (todayWaterMl / target).clamp(0.0, 1.0);
    final percent = ((todayWaterMl / target) * 100).round();

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Icon + Judul + Persentase
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer.withAlpha(120),
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
                        child: Text(
                          'Konsumsi Air Hari Ini',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Text(
                  '$percent%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),

            // Angka Asupan
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$todayWaterMl',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'ml',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    '/ $target ml target harian',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),

            // Progress Bar Air Minum
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),

            // Keterangan Quick-Log
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: colorScheme.tertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Catat cepat 1-ketuk tanpa pindah halaman:',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),

            // 3 Tombol Catat Cepat: +150 ml, +250 ml, +500 ml
            Row(
              children: [
                Expanded(
                  child: _buildWaterButton(
                    context,
                    theme,
                    colorScheme,
                    amount: 150,
                    portionLabel: '1 Cangkir',
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: _buildWaterButton(
                    context,
                    theme,
                    colorScheme,
                    amount: 250,
                    portionLabel: '1 Gelas',
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: _buildWaterButton(
                    context,
                    theme,
                    colorScheme,
                    amount: 500,
                    portionLabel: '1 Botol',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required int amount,
    required String portionLabel,
  }) {
    return InkWell(
      onTap: () => _addWater(amount),
      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+$amount ml',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.tertiary,
              ),
            ),
            Text(
              portionLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 5: TODAY'S MENU (MENU HARI INI)
  // ---------------------------------------------------------------------------

  Widget _buildTodayMenuSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    const dayNames = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Minggu',
    };
    final todayDayName = dayNames[DateTime.now().weekday] ?? 'Hari Ini';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Judul Menu Hari Ini + Chip Hari + Link Lihat Rencana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Menu Hari Ini',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusFull,
                      ),
                    ),
                    child: Text(
                      todayDayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spaceXs),
            TextButton.icon(
              onPressed: _navigateToMealPlan,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.chevron_right, size: 18),
              label: const Text('Lihat Rencana'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceSm),

        // Daftar Menu atau Tampilan Kosong (Empty State)
        if (todayMeals.isEmpty)
          _buildEmptyMenuCard(context, theme, colorScheme)
        else
          ...List.generate(todayMeals.length, (index) {
            final meal = todayMeals[index];
            final isEaten = index < todayEaten.length && todayEaten[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
              child: _buildMealItem(
                context,
                theme,
                colorScheme,
                meal: meal,
                isEaten: isEaten,
                slotIndex: index,
              ),
            );
          }),
      ],
    );
  }

  /// Tampilan jika belum ada jadwal makanan untuk hari ini.
  Widget _buildEmptyMenuCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: AppConstants.spaceLg,
        ),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 44,
              color: colorScheme.primary,
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'Belum ada menu hari ini',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXs),
            Text(
              'Mulai rencanakan menu mingguan hematmu sekarang!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceMd),
            FilledButton.tonalIcon(
              onPressed: _navigateToMealPlan,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Rencanakan Menu'),
            ),
          ],
        ),
      ),
    );
  }

  /// Kartu makanan individual sesuai desain HTML Beranda (lines 151-210).
  Widget _buildMealItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required Meal meal,
    required bool isEaten,
    required int slotIndex,
  }) {
    // Estimasi jam makan berdasarkan slot index atau kategori
    final timeStr = _getMealTime(slotIndex, meal.category);
    final indicatorColor = _getCategoryColor(meal.category, colorScheme);

    // Cek Alergen pengguna vs Alergen makanan (PRD FR-12)
    final matchedAllergens = meal.allergens
        .where(
          (a) => profile.allergies.any(
            (userAllergy) =>
                userAllergy.trim().toLowerCase() == a.trim().toLowerCase(),
          ),
        )
        .toList();

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Indikator Warna Kategori Vertikal
                Container(
                  width: 5,
                  height: 56,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),

                // Gambar Menu dengan Fallback
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  child: Image.asset(
                    meal.imageAsset,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 56,
                      color: colorScheme.surfaceContainerHigh,
                      child: Icon(
                        Icons.restaurant,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),

                // Informasi Menu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              meal.category.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: indicatorColor,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '• $timeStr',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
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
                      const SizedBox(height: 2),
                      Text(
                        '${formatRupiah(meal.price)} • ${meal.calories} kkal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkbox Status Selesai Dimakan
                Semantics(
                  label: 'Centang ${meal.name}',
                  child: Checkbox(
                    value: isEaten,
                    activeColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSm,
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        onToggleMealEaten?.call(slotIndex, val);
                      }
                    },
                  ),
                ),
              ],
            ),

            // Alert Alergen jika ada kecocokan dengan alergi profil
            if (matchedAllergens.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spaceXs),
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withAlpha(200),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Peringatan: Mengandung Alergen ${matchedAllergens.join(', ')}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onErrorContainer,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMealTime(int slotIndex, String category) {
    final lower = category.toLowerCase();
    if (lower.contains('sarapan')) return '07:30';
    if (lower.contains('siang')) return '12:30';
    if (lower.contains('malam')) return '19:00';
    switch (slotIndex) {
      case 0:
        return '07:30';
      case 1:
        return '12:30';
      case 2:
        return '19:00';
      default:
        return '12:00';
    }
  }

  Color _getCategoryColor(String category, ColorScheme colorScheme) {
    final lower = category.toLowerCase();
    if (lower.contains('sarapan')) return colorScheme.primary;
    if (lower.contains('siang')) return colorScheme.secondary;
    return colorScheme.outlineVariant;
  }

  // ---------------------------------------------------------------------------
  // SECTION 6: ZERO FOOD WASTE COMMITMENT CARD (SDG 12.3)
  // ---------------------------------------------------------------------------

  Widget _buildZeroWasteCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.recycling,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Pahlawan Bebas Sampah',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Habiskan makanan untuk capai SDG 12.3',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceSm),
                FilledButton.tonal(
                  onPressed: onNoWaste,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurface,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Habis Semua! 🌟',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.recycling,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pahlawan Bebas Sampah',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Habiskan makanan untuk capai SDG 12.3',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              FilledButton.tonal(
                onPressed: onNoWaste,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                  visualDensity: VisualDensity.compact,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Habis Semua! 🌟',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
