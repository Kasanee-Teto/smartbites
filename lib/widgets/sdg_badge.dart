// Owner: Louis | FR: FR-01, FR-03

import 'package:budget_bites/utils/app_constants.dart';
import 'package:flutter/material.dart';

enum SdgType {
  sdg3,
  sdg12,
  both,
}

/// A compact, accessible badge displaying SDG 3 (Good Health and Well-being)
/// and SDG 12.3 (Halve Food Waste), matching the HTML header and card tags.
class SdgBadge extends StatelessWidget {
  final SdgType type;
  final bool compact;

  const SdgBadge({
    super.key,
    this.type = SdgType.both,
    this.compact = false,
  });

  const SdgBadge.sdg3({super.key, this.compact = false}) : type = SdgType.sdg3;
  const SdgBadge.sdg12({super.key, this.compact = false}) : type = SdgType.sdg12;
  const SdgBadge.both({super.key, this.compact = false}) : type = SdgType.both;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (compact) {
      final (label, bg, fg) = switch (type) {
        SdgType.sdg3 => (
            'SDG 3',
            colorScheme.tertiaryFixedDim,
            colorScheme.onTertiaryFixed,
          ),
        SdgType.sdg12 => (
            'SDG 12.3',
            colorScheme.secondaryFixedDim,
            colorScheme.onSecondaryFixed,
          ),
        SdgType.both => (
            'SDG 3 & 12.3',
            colorScheme.secondaryFixed,
            colorScheme.onSecondaryFixed,
          ),
      };

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.bold,
            fontSize: 9.0,
          ),
        ),
      );
    }

    final (label, dotColor) = switch (type) {
      SdgType.sdg3 => ('SDG 3: Kehidupan Sehat', colorScheme.primary),
      SdgType.sdg12 => ('SDG 12.3: Nol Sampah Pangan', colorScheme.secondary),
      SdgType.both => (
          'SDG 3 & 12.3: Sehat & Berkelanjutan',
          colorScheme.primary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.only(right: 6.0),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            TextSpan(
              text: label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
