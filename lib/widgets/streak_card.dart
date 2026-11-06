// Owner: Louis | FR: FR-36, FR-38, FR-40
// Design reference: stitch_smartbites_meal_budget_planner/smartbites_beranda/code.html (Lines 81-97)

import 'package:budget_bites/utils/app_constants.dart';
import 'package:flutter/material.dart';

/// Kartu gamifikasi konsistensi harian (StreakCard) sesuai desain Beranda.
///
/// Menampilkan jumlah hari beruntun, badge milestone level, serta status
/// motivasi tanpa kata-kata menyalahkan (PRD 6.2 & Task T7).
class StreakCard extends StatelessWidget {
  const StreakCard({
    required this.streak,
    required this.level,
    required this.nextTarget,
    required this.progress,
    this.onTap,
    this.isLoggedToday = true,
    this.isBroken = false,
    super.key,
  });

  /// Jumlah hari aktif beruntun saat ini.
  final int streak;

  /// Tingkat kebiasaan (Level 1: 0-2 hari, Level 2: 3-6 hari, Level 3: 7+ hari).
  final int level;

  /// Target lencana berikutnya (mis. 3 atau 7 hari).
  final int nextTarget;

  /// Kemajuan saat ini menuju [nextTarget].
  final int progress;

  /// Callback navigasi saat kartu diketuk (membuka layar Profil / Pencapaian).
  final VoidCallback? onTap;

  /// Apakah pengguna sudah mencatat setidaknya satu aktivitas hari ini.
  final bool isLoggedToday;

  /// Menandai apakah streak baru saja terputus setelah sebelumnya aktif.
  final bool isBroken;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasStreak = streak > 0;

    // Menentukan teks motivasi ramah pengguna berdasarkan status streak
    final String subtitle;
    if (!hasStreak) {
      subtitle = isBroken
          ? 'Streak-mu istirahat dulu. Yuk mulai lagi!'
          : 'Mulai streak pertamamu hari ini!';
    } else if (!isLoggedToday) {
      subtitle = 'Catat satu hal hari ini untuk menjaga streak';
    } else {
      subtitle = 'Pertahankan kebiasaan sehat dan hematmu!';
    }

    final titleText = hasStreak
        ? '$streak Hari Beruntun 🔥'
        : 'Mulai Beruntun Pertamamu! 🔥';

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
          child: Row(
            children: [
              // 1. Lingkaran Ikon Api (Flame Icon)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasStreak
                      ? colorScheme.secondaryFixed
                      : colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: hasStreak
                      ? colorScheme.secondary
                      : colorScheme.onSurfaceVariant,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm + 4),

              // 2. Info Streak & Level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            titleText,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusSm,
                            ),
                          ),
                          child: Text(
                            'Level $level',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondaryFixed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),

              // 3. Tombol Panah Navigasi ke Pencapaian
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
