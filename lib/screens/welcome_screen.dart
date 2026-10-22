// Owner: Louis | FR: FR-01
// Design: stitch_smartbites_meal_budget_planner/smartbites_welcome_onboarding/code.html

import 'package:budget_bites/screens/onboarding_screen.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/app_logo.dart';
import 'package:budget_bites/widgets/main_navigation.dart';
import 'package:budget_bites/widgets/responsive_layout.dart';
import 'package:budget_bites/widgets/sdg_badge.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const WelcomeScreen({
    super.key,
    this.onGetStarted,
  });

  void _navigateToOnboarding(BuildContext context) {
    if (onGetStarted != null) {
      onGetStarted!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const OnboardingScreen(),
      ),
    );
  }

  void _navigateToMainNavigation(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const MainNavigation(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveLayout(
          compact: (context) => _buildCompactLayout(context),
          medium: (context) => _buildWideLayout(context, WindowSize.medium),
          expanded: (context) => _buildWideLayout(context, WindowSize.expanded),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.spaceMd),

          // Header: Logo + App Name + Version Badge
          Center(
            child: Column(
              children: [
                const AppLogo(size: 80.0),
                const SizedBox(height: AppConstants.spaceSm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryFixed,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusFull),
                        ),
                        child: Text(
                          'v1.0',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryFixed,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Sahabat Sehat Anak Kos',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),

          // SDG Impact Badges
          const Center(
            child: Wrap(
              spacing: AppConstants.spaceSm,
              runSpacing: AppConstants.spaceXs,
              alignment: WrapAlignment.center,
              children: [
                SdgBadge.sdg3(),
                SdgBadge.sdg12(),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),

          // Hero Presentation Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              side: BorderSide(
                color: colorScheme.outlineVariant.withAlpha(80),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pola Makan Sehat & Hemat Tanpa Boros',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  Text(
                    'Rencanakan menu harian murah, pantau hidrasi tubuh dengan 1 ketukan, kelola anggaran belanja pasar, dan kurangi sisa makanan basi di kos.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),

                  // Empathy Highlight Box
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceSm),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.0,
                          height: 36.0,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryFixed,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.school,
                            size: 20.0,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dibuat khusus untuk mahasiswa kos ❤️',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Resep realistis: tanpa kulkas besar, tanpa bumbu mahal.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceXl),

          // Primary CTA: Mulai
          FilledButton(
            onPressed: () => _navigateToOnboarding(context),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: AppConstants.spaceMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mulai Rencanakan Makan',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: AppConstants.spaceSm),
                  Text('🚀', style: TextStyle(fontSize: 18.0)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),

          // Secondary CTA: Langsung Masuk (Demo)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: TextButton.icon(
              onPressed: () => _navigateToMainNavigation(context),
              icon: const Icon(Icons.dataset_outlined, size: 18.0),
              label: const Text('Sudah punya data demo? Masuk Langsung'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // Footer Academic Credits
          Center(
            child: Column(
              children: [
                Text(
                  'Proyek Flutter MD3 • Pemrograman Mobile',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Teknik Informatika • Indonesia Mandiri Sehat',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                    fontSize: 9.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, WindowSize size) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680.0),
        child: Card(
          elevation: 1.0,
          margin: const EdgeInsets.all(AppConstants.spaceLg),
          child: _buildCompactLayout(context),
        ),
      ),
    );
  }
}
