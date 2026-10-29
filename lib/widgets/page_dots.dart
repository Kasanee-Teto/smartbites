// Owner: Louis | FR: FR-01, FR-03
// Documented addition to PRD 9.1: Reusable pagination dot indicator
// Reused in OnboardingScreen (Step 3) and Health Tip Carousel (Step 10).

import 'package:budget_bites/utils/app_constants.dart';
import 'package:flutter/material.dart';

class PageDots extends StatelessWidget {
  const PageDots({
    required this.count,
    required this.currentIndex,
    super.key,
    this.onDotTapped,
  });
  final int count;
  final int currentIndex;
  final ValueChanged<int>? onDotTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Halaman ${currentIndex + 1} dari $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = index == currentIndex;
          return GestureDetector(
            onTap: onDotTapped != null ? () => onDotTapped!(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 24.0 : 8.0,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
            ),
          );
        }),
      ),
    );
  }
}
