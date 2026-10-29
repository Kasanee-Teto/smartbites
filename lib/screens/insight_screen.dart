// Owner: Gilbert | FR: FR-07
// Design: stitch_smartbites_meal_budget_planner/smartbites_beranda/code.html

import 'dart:math' as math;

import 'package:budget_bites/utils/app_colors.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/widgets/responsive_layout.dart';
import 'package:budget_bites/widgets/sdg_badge.dart';
import 'package:budget_bites/widgets/section_title.dart';
import 'package:budget_bites/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Weekly Insights screen (FR-07) presenting budget usage, a widget-based
/// 7-day spending bar chart without external chart packages, category spending
/// breakdown, and practical student budget-saving tips.
class InsightScreen extends StatelessWidget {
  const InsightScreen({
    super.key,
    this.currentSpent = 0,
    this.weeklyBudget = 300000,
    this.onBack,
  });

  final int currentSpent;
  final int weeklyBudget;
  final VoidCallback? onBack;

  static const List<String> _dayLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  // Sample daily distribution weights (7 days summing to 100%)
  static const List<double> _dayWeights = [
    0.16,
    0.14,
    0.18,
    0.12,
    0.15,
    0.14,
    0.11,
  ];

  List<int> get _dailySpend {
    final safeSpent = math.max(0, currentSpent);
    if (safeSpent == 0) {
      return List<int>.filled(7, 0);
    }
    final result = <int>[];
    var allocated = 0;
    for (var i = 0; i < _dayWeights.length; i++) {
      if (i == _dayWeights.length - 1) {
        result.add(math.max(0, safeSpent - allocated));
      } else {
        final share = ((safeSpent * _dayWeights[i]) / 500).round() * 500;
        result.add(share);
        allocated += share;
      }
    }
    return result;
  }

  StatusBadge _buildStatusBadge(int safeSpent, int safeBudget) {
    if (safeBudget <= 0) {
      return safeSpent > 0 ? StatusBadge.melebihi() : StatusBadge.pas();
    }
    final ratio = safeSpent / safeBudget;
    if (ratio > 1.0) {
      return StatusBadge.melebihi();
    }
    if (ratio >= 0.85) {
      return StatusBadge.pas();
    }
    return StatusBadge.hemat();
  }

  Widget _buildBudgetOverviewCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final safeSpent = math.max(0, currentSpent);
    final safeBudget = math.max(0, weeklyBudget);
    final remaining = safeBudget - safeSpent;
    final isOverBudget = remaining < 0;
    final ratio = safeBudget > 0
        ? (safeSpent / safeBudget).clamp(0.0, 1.0)
        : (safeSpent > 0 ? 1.0 : 0.0);
    final percentage = safeBudget > 0
        ? ((safeSpent / safeBudget) * 100).round()
        : 0;
    final dailyAverage = (safeSpent / 7).round();

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusDefault,
                          ),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ringkasan Anggaran Mingguan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Estimasi pengeluaran Senin – Minggu',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
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
                _buildStatusBadge(safeSpent, safeBudget),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      text: formatRupiah(safeSpent),
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isOverBudget
                            ? colorScheme.error
                            : colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: ' / ${formatRupiah(safeBudget)}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isOverBudget
                        ? colorScheme.error
                        : colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: isOverBudget ? colorScheme.error : colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                Expanded(
                  child: _buildStatPill(
                    context,
                    icon: isOverBudget
                        ? Icons.warning_amber_rounded
                        : Icons.savings_outlined,
                    label: isOverBudget ? 'Selisih Lebih' : 'Sisa Anggaran',
                    value: formatRupiah(remaining.abs()),
                    valueColor: isOverBudget
                        ? colorScheme.error
                        : colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: _buildStatPill(
                    context,
                    icon: Icons.calendar_today_outlined,
                    label: 'Rata-rata / Hari',
                    value: formatRupiah(dailyAverage),
                    valueColor: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: valueColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget-based bar chart without external packages (FR-07).
  Widget _buildWeeklyBarChartCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final dailyValues = _dailySpend;
    final safeBudget = math.max(0, weeklyBudget);
    final dailyTarget = safeBudget > 0 ? (safeBudget / 7).round() : 0;
    final maxVal = dailyValues.fold<int>(
      dailyTarget > 0 ? dailyTarget : 1,
      math.max,
    );

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Grafik Pengeluaran 7 Hari',
              trailing: SdgBadge.both(compact: true),
            ),
            Text(
              dailyTarget > 0
                  ? 'Target rata-rata harian: ${formatRupiah(dailyTarget)}'
                  : 'Belum ada batas anggaran harian yang ditetapkan',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SizedBox(
              height: 168,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_dayLabels.length, (index) {
                  final amount = dailyValues[index];
                  final ratio = maxVal > 0
                      ? (amount / maxVal).clamp(0.06, 1.0)
                      : 0.06;
                  final isAboveDailyTarget =
                      dailyTarget > 0 && amount > dailyTarget;
                  final barColor = amount == 0
                      ? colorScheme.outlineVariant
                      : isAboveDailyTarget
                      ? AppColors.harvestAmber
                      : colorScheme.primary;
                  final shortK = amount >= 1000
                      ? '${(amount / 1000).round()}rb'
                      : '$amount';

                  return Expanded(
                    child: Semantics(
                      label: '${_dayLabels[index]}: ${formatRupiah(amount)}',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              shortK,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: amount == 0 ? 0.06 : ratio,
                                  widthFactor: 0.65,
                                  child: Container(
                                    key: Key('insight_bar_$index'),
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(
                                          AppConstants.radiusSm,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _dayLabels[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Wrap(
              spacing: AppConstants.spaceMd,
              runSpacing: AppConstants.spaceXs,
              children: [
                _buildLegendItem(
                  context,
                  color: colorScheme.primary,
                  label: 'Sesuai target harian',
                ),
                _buildLegendItem(
                  context,
                  color: AppColors.harvestAmber,
                  label: 'Di atas rata-rata harian',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdownCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final safeSpent = math.max(0, currentSpent);

    final categories = <({String name, double share, IconData icon, Color fg})>[
      (
        name: 'Protein & Lauk (Tempe, Tahu, Telur)',
        share: 0.42,
        icon: Icons.egg_outlined,
        fg: colorScheme.primary,
      ),
      (
        name: 'Sayuran & Buah Segar',
        share: 0.28,
        icon: Icons.eco_outlined,
        fg: AppColors.hydrationBlue,
      ),
      (
        name: 'Bahan Pokok (Beras, Oatmeal, Roti)',
        share: 0.20,
        icon: Icons.rice_bowl_outlined,
        fg: AppColors.harvestAmber,
      ),
      (
        name: 'Bumbu & Pelengkap Dapur',
        share: 0.10,
        icon: Icons.spa_outlined,
        fg: colorScheme.secondary,
      ),
    ];

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Alokasi Kategori Belanja'),
            const SizedBox(height: AppConstants.spaceXs),
            ...categories.map((cat) {
              final amount = (safeSpent * cat.share).round();
              final pct = (cat.share * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(cat.icon, size: 18, color: cat.fg),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cat.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${formatRupiah(amount)} ($pct%)',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusFull,
                      ),
                      child: LinearProgressIndicator(
                        value: cat.share,
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: cat.fg,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingTipsCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const tips = <({String title, String subtitle, IconData icon})>[
      (
        title: 'Belanja Sayur di Pasar Pagi',
        subtitle:
            'Harga sayuran segar dan tempe di pasar tradisional rata-rata '
            'lebih hemat dibanding ritel modern.',
        icon: Icons.storefront_outlined,
      ),
      (
        title: 'Cek Stok Pantry Sebelum Belanja',
        subtitle:
            'Prioritaskan bahan yang mendekati tanggal kedaluwarsa agar '
            'tidak terbuang sia-sia (SDG 12.3).',
        icon: Icons.kitchen_outlined,
      ),
      (
        title: 'Kombinasi Protein Nabati & Telur',
        subtitle:
            'Tahu, tempe, dan telur memberi asupan protein harian dengan '
            'biaya per porsi yang ramah saku kos.',
        icon: Icons.tips_and_updates_outlined,
      ),
    ];

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Tips Hemat & Anti-Mubazir'),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tip.icon,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.title,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tip.subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      children: [
        _buildBudgetOverviewCard(context),
        const SizedBox(height: AppConstants.spaceMd),
        _buildWeeklyBarChartCard(context),
        const SizedBox(height: AppConstants.spaceMd),
        _buildCategoryBreakdownCard(context),
        const SizedBox(height: AppConstants.spaceMd),
        _buildSavingTipsCard(context),
      ],
    );
  }

  Widget _buildWideContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxContentWidth,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildBudgetOverviewCard(context),
                    const SizedBox(height: AppConstants.spaceMd),
                    _buildWeeklyBarChartCard(context),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  children: [
                    _buildCategoryBreakdownCard(context),
                    const SizedBox(height: AppConstants.spaceMd),
                    _buildSavingTipsCard(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final showLeading = onBack != null || canPop;

    return Scaffold(
      appBar: AppBar(
        leading: showLeading
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Kembali',
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              )
            : null,
        title: const Text('Insight Mingguan'),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          compact: _buildCompactContent,
          medium: _buildWideContent,
          expanded: _buildWideContent,
        ),
      ),
    );
  }
}
