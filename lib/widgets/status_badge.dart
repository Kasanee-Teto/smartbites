// Owner: Louis | FR: FR-03, FR-04, FR-12

import 'package:budget_bites/utils/app_constants.dart';
import 'package:flutter/material.dart';

enum StatusBadgeType {
  success, // Hemat, Selesai, Fresh
  warning, // Pas, Menipis, Sedang
  danger,  // Melebihi budget, Kadaluarsa, Alergen
  info,    // Kategori menu, Netral, Jadwal
}

class StatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final StatusBadgeType type;
  final VoidCallback? onTap;

  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.type = StatusBadgeType.info,
    this.onTap,
  });

  /// Factory helper untuk status anggaran 'Hemat'
  factory StatusBadge.hemat({Key? key, VoidCallback? onTap}) {
    return StatusBadge(
      key: key,
      label: 'Hemat',
      icon: Icons.check_circle_outline,
      type: StatusBadgeType.success,
      onTap: onTap,
    );
  }

  /// Factory helper untuk status anggaran 'Pas'
  factory StatusBadge.pas({Key? key, VoidCallback? onTap}) {
    return StatusBadge(
      key: key,
      label: 'Pas',
      icon: Icons.info_outline,
      type: StatusBadgeType.warning,
      onTap: onTap,
    );
  }

  /// Factory helper untuk status anggaran 'Melebihi'
  factory StatusBadge.melebihi({Key? key, VoidCallback? onTap}) {
    return StatusBadge(
      key: key,
      label: 'Perlu Hemat',
      icon: Icons.warning_amber_rounded,
      type: StatusBadgeType.danger,
      onTap: onTap,
    );
  }

  /// Factory helper untuk peringatan alergen
  factory StatusBadge.alergen({
    Key? key,
    required String name,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      key: key,
      label: name,
      icon: Icons.warning_amber_rounded,
      type: StatusBadgeType.danger,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (Color bgColor, Color fgColor) = switch (type) {
      StatusBadgeType.success => (
          colorScheme.surfaceContainerLow,
          colorScheme.primary,
        ),
      StatusBadgeType.warning => (
          colorScheme.secondaryContainer.withAlpha(50),
          colorScheme.secondary,
        ),
      StatusBadgeType.danger => (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
        ),
      StatusBadgeType.info => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
        ),
    };

    final content = Container(
      constraints: const BoxConstraints(minHeight: 28.0),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14.0,
              color: fgColor,
            ),
            const SizedBox(width: AppConstants.spaceXs),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        child: content,
      );
    }

    return content;
  }
}
