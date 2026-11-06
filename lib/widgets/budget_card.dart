// Owner: Louis | FR: FR-04, FR-13
// Design: stitch_smartbites_meal_budget_planner/smartbites_beranda/code.html
// and smartbites_perencana_makan/code.html

import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/budget_status.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Kartu ringkasan anggaran makan mingguan yang dapat digunakan secara fleksibel
/// di layar Beranda (mode standar) dan Perencana Makan (mode compact).
class BudgetCard extends StatelessWidget {
  const BudgetCard({
    required this.spent,
    required this.budget,
    this.compact = false,
    this.title,
    this.subtitle,
    this.remainingDays = 3,
    this.onTap,
    super.key,
  });

  /// Total pengeluaran yang telah dicatat atau direncanakan.
  final int spent;

  /// Batas anggaran mingguan yang ditetapkan pengguna.
  final int budget;

  /// Menentukan apakah kartu ditampilkan dalam format mini/ringkas (Perencana Makan)
  /// atau format lengkap (Beranda).
  final bool compact;

  /// Judul kustom untuk kartu anggaran.
  final String? title;

  /// Subtitle kustom untuk kartu anggaran.
  final String? subtitle;

  /// Jumlah hari tersisa dalam siklus minggu berjalan (default 3 hari).
  final int remainingDays;

  /// Callback opsional saat kartu ditekan (misal navigasi ke Insight atau Profil).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Normalisasi input dan hitung status
    final safeSpent = spent < 0 ? 0 : spent;
    final isUnset = budget <= 0;
    final status = budgetStatus(safeSpent, budget);
    final ratio = isUnset ? 0.0 : safeSpent / budget;
    final clampedRatio = ratio.clamp(0.0, 1.0);
    final percentInt = (ratio * 100).round();

    // Widget badge status
    final badgeWidget = switch (status) {
      BudgetStatus.hemat => StatusBadge(
        label: compact ? 'Hemat (Di Bawah Target)' : 'Hemat',
        icon: Icons.check_circle_outline,
        type: StatusBadgeType.success,
      ),
      BudgetStatus.pas => StatusBadge(
        label: compact ? 'Pas Target' : 'Pas',
        icon: Icons.info_outline,
        type: StatusBadgeType.warning,
      ),
      BudgetStatus.melebihi => StatusBadge(
        label: compact ? 'Melebihi Target' : 'Perlu Hemat',
        icon: Icons.warning_amber_rounded,
        type: StatusBadgeType.danger,
      ),
      BudgetStatus.belumDiatur => const StatusBadge(
        label: 'Atur di Profil',
        icon: Icons.tune,
        type: StatusBadgeType.warning,
      ),
    };

    final progressColor = status == BudgetStatus.melebihi
        ? colorScheme.error
        : (status == BudgetStatus.pas
              ? colorScheme.secondary
              : colorScheme.primary);

    Widget content;
    if (compact) {
      content = _buildCompactContent(
        context,
        theme,
        colorScheme,
        safeSpent,
        isUnset,
        badgeWidget,
        clampedRatio,
        percentInt,
        progressColor,
      );
    } else {
      content = _buildStandardContent(
        context,
        theme,
        colorScheme,
        safeSpent,
        isUnset,
        badgeWidget,
        clampedRatio,
        percentInt,
        progressColor,
      );
    }

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: content,
        ),
      ),
    );
  }

  /// Tampilan ringkas untuk Perencana Makan (mini status block).
  Widget _buildCompactContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    int safeSpent,
    bool isUnset,
    Widget badgeWidget,
    double clampedRatio,
    int percentInt,
    Color progressColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Baris Atas: Label & Status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppConstants.spaceXs),
                      Flexible(
                        child: Text(
                          title ?? 'Total Rencana Mingguan',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatRupiah(safeSpent),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            badgeWidget,
          ],
        ),
        const SizedBox(height: AppConstants.spaceSm),

        // Linear Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          child: LinearProgressIndicator(
            value: clampedRatio,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        const SizedBox(height: 6),

        // Subtext Keterangan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isUnset ? 'Budget belum diatur' : 'Terpakai $percentInt%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              isUnset
                  ? 'Atur budget di Profil'
                  : 'Budget Maks: ${formatRupiah(budget)}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isUnset ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Tampilan lengkap untuk Beranda (HTML Beranda lines 44-79).
  Widget _buildStandardContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    int safeSpent,
    bool isUnset,
    Widget badgeWidget,
    double clampedRatio,
    int percentInt,
    Color progressColor,
  ) {
    final isOver = !isUnset && safeSpent > budget;
    final diff = (budget - safeSpent).abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Header: Icon + Title + Subtitle & Status Badge
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
                        AppConstants.radiusMd,
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
                          title ?? 'Budget Makan Minggu Ini',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle ?? 'Target Senin – Minggu',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),
            badgeWidget,
          ],
        ),
        const SizedBox(height: AppConstants.spaceMd),

        // 2. Spent / Budget amount & Percentage
        if (isUnset) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceSm,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    'Atur budget di Profil untuk memantau pengeluaran.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        formatRupiah(safeSpent),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '/ ${formatRupiah(budget)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                '$percentInt%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),

          // 3. Smooth Linear Progress Indicator Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: clampedRatio,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),

          // 4. Footer: Sisa / Lebih & Sisa Hari
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOver
                          ? Icons.warning_amber_rounded
                          : Icons.savings_outlined,
                      size: 16,
                      color: isOver ? colorScheme.error : colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: isOver ? 'Lebih: ' : 'Sisa uang makan: ',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            TextSpan(
                              text: formatRupiah(diff),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isOver
                                    ? colorScheme.error
                                    : colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                'Tersisa $remainingDays hari',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
