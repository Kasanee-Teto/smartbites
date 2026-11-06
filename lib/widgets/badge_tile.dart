// Owner: Edbert | FR: FR-37, FR-38

import 'package:budget_bites/models/achievement.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/badge_rules.dart';
import 'package:budget_bites/widgets/asset_image.dart';
import 'package:budget_bites/widgets/status_badge.dart';
import 'package:flutter/material.dart';

class BadgeTile extends StatelessWidget {
  const BadgeTile({required this.achievement, super.key, this.onTap});

  final Achievement achievement;
  final VoidCallback? onTap;

  double get _progressValue {
    if (achievement.target <= 0) return 0;
    return (achievement.progress / achievement.target).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unlocked = achievement.isUnlocked;

    final semanticsLabel = unlocked
        ? '${achievement.title}, terbuka'
        : '${achievement.title}, terkunci, progres '
              '${achievement.progress} dari ${achievement.target}';

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: unlocked
                            ? colorScheme.secondaryContainer.withAlpha(60)
                            : colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    Opacity(
                      opacity: unlocked ? 1 : 0.4,
                      child: AssetImageWithFallback(
                        assetPath: achievement.iconAsset,
                        fallbackIcon: BadgeRules.iconFor(achievement.id),
                        width: 64,
                        height: 64,
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    if (!unlocked)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: colorScheme.surface,
                          child: Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Text(
                  achievement.title,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spaceXs),
                Text(
                  achievement.description,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spaceSm),
                if (unlocked)
                  const StatusBadge(
                    label: 'Terbuka',
                    icon: Icons.check_circle_outline,
                    type: StatusBadgeType.success,
                  )
                else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull,
                    ),
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text(
                    '${achievement.progress} / ${achievement.target}',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
