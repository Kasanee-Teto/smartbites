// Owner: Louis | FR: FR-01..07

import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/widgets/app_logo.dart';
import 'package:flutter/material.dart';

class SmartBitesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SmartBitesAppBar({
    super.key,
    this.subtitle = 'Beranda',
    this.streakDays = 7,
    this.onNotificationTap,
    this.onProfileTap,
    this.onStreakTap,
  });
  final String subtitle;
  final int streakDays;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onStreakTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceSm),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withAlpha(50),
              ),
            ),
          ),
          child: Row(
            children: [
              // Bagian Kiri: Logo + Nama Aplikasi + Subtitle
              Expanded(
                child: Row(
                  children: [
                    const AppLogo(size: 32),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  AppConstants.appName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spaceXs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer
                                      .withAlpha(50),
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  'SDG',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.secondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                  ],
                ),
              ),

              const SizedBox(width: AppConstants.spaceXs),

              // Bagian Kanan: Lencana Streak + Notifikasi + Avatar Profil
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lencana Streak
                  if (streakDays > 0)
                    InkWell(
                      onTap: onStreakTap,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusFull,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withAlpha(60),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusFull,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 16,
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$streakDays',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Tombol Notifikasi (Touch target >= 48dp)
                  IconButton(
                    tooltip: 'Notifikasi',
                    icon: const Icon(Icons.notifications_outlined),
                    color: colorScheme.onSurfaceVariant,
                    onPressed: onNotificationTap ?? () {},
                  ),

                  // Avatar Profil (Touch target >= 48dp)
                  InkWell(
                    onTap: onProfileTap ?? () {},
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spaceXs),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
