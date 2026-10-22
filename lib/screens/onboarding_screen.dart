// Owner: Louis | FR: FR-01
// Design: stitch_smartbites_meal_budget_planner/smartbites_welcome_onboarding/code.html

import 'package:budget_bites/models/user_profile.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/app_logo.dart';
import 'package:budget_bites/widgets/asset_image_with_fallback.dart';
import 'package:budget_bites/widgets/main_navigation.dart';
import 'package:budget_bites/widgets/page_dots.dart';
import 'package:budget_bites/widgets/sdg_badge.dart';
import 'package:flutter/material.dart';

class OnboardingBullet {
  final IconData icon;
  final String title;
  final String description;
  final String? sdgTag;

  const OnboardingBullet({
    required this.icon,
    required this.title,
    required this.description,
    this.sdgTag,
  });
}

class OnboardingSlide {
  final String imageAsset;
  final String category;
  final String title;
  final String badgeText;
  final IconData badgeIcon;
  final String? secondaryBadgeText;
  final IconData? secondaryBadgeIcon;
  final List<OnboardingBullet> bullets;

  const OnboardingSlide({
    required this.imageAsset,
    required this.category,
    required this.title,
    required this.badgeText,
    required this.badgeIcon,
    this.secondaryBadgeText,
    this.secondaryBadgeIcon,
    required this.bullets,
  });
}

const List<OnboardingSlide> _slides = [
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding_1.png',
    category: 'POLA MAKAN ANTI KANKER (KANTONG KERING)',
    title: 'Makan Enak, Hemat & Sehat Tanpa Boros',
    badgeText: 'Rp 12.500 / porsi',
    badgeIcon: Icons.eco,
    secondaryBadgeText: '500ml Tercatat',
    secondaryBadgeIcon: Icons.water_drop,
    bullets: [
      OnboardingBullet(
        icon: Icons.calendar_month,
        title: 'Menu Mingguan Ramah Kantong Kos',
        description:
            'Optimasi belanja pasar mingguan mulai Rp 75.000 per minggu.',
      ),
      OnboardingBullet(
        icon: Icons.water_drop,
        title: 'Pantau Hidrasi 1-Ketukan',
        description:
            'Target harian 2 liter air terjaga tanpa repot mengetik detail.',
        sdgTag: 'SDG 3',
      ),
      OnboardingBullet(
        icon: Icons.inventory_2,
        title: 'Pantry Pintar Anti Basi',
        description:
            'Pengingat kadaluwarsa bahan makanan & kreasi resep sisa kulkas.',
        sdgTag: 'SDG 12.3',
      ),
    ],
  ),
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding_2.png',
    category: 'TRANSPARANSI DOMPET MAHASISWA',
    title: 'Alokasi Uang Makan Realistis',
    badgeText: 'Hemat 35% Bulanan',
    badgeIcon: Icons.savings,
    bullets: [
      OnboardingBullet(
        icon: Icons.price_change,
        title: 'Target Harian Rp 30.000 - Rp 50.000',
        description:
            'Pengingat pintar jika jajan melebihi batas aman hari ini.',
      ),
      OnboardingBullet(
        icon: Icons.shopping_basket,
        title: 'Daftar Belanja Pasar Tradisional',
        description:
            'Dikelompokkan otomatis berdasarkan lorong sayur, bumbu & lauk.',
      ),
      OnboardingBullet(
        icon: Icons.receipt_long,
        title: 'Pencatatan Cepat < 10 Detik',
        description: 'Tanpa ribet input manual rincian struk belanjaan.',
      ),
    ],
  ),
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding_3.png',
    category: 'MISI HARIAN MENYENANGKAN',
    title: 'Bentuk Rutinitas Sehat & Berkelanjutan',
    badgeText: '8 Lencana Siap Diraih',
    badgeIcon: Icons.verified,
    bullets: [
      OnboardingBullet(
        icon: Icons.local_fire_department,
        title: 'Konsistensi Streak Harian',
        description:
            'Bangun kebiasaan makan teratur dan minum air cukup setiap hari.',
      ),
      OnboardingBullet(
        icon: Icons.recycling,
        title: 'Hitung Pengurangan Emisi Karbon',
        description:
            'Lihat langsung berapa gram makanan yang berhasil kamu selamatkan.',
      ),
      OnboardingBullet(
        icon: Icons.tips_and_updates,
        title: 'Tips Anak Kos Realistis',
        description:
            'Resep praktis hanya bermodal rice cooker atau teflon satu wajan.',
      ),
    ],
  ),
];

class OnboardingScreen extends StatefulWidget {
  final ValueChanged<UserProfile>? onFinish;

  const OnboardingScreen({
    super.key,
    this.onFinish,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    if (widget.onFinish != null) {
      widget.onFinish!(
        const UserProfile(
          weeklyBudget: 300000,
          waterTargetMl: 2000,
          allergies: [],
          preferences: ['Hemat', 'Tinggi Protein'],
          darkMode: false,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const MainNavigation(),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) {
          _previousPage();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final windowSize = windowSizeFor(constraints.maxWidth);
              final isWide = windowSize != WindowSize.compact;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 880.0 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      // 1. Top Bar: Logo, Title, SDG Badges, Lewati button
                      _buildTopBar(context),

                      // 2. PageView carousel taking remaining space
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _slides.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _buildSlide(
                              context,
                              _slides[index],
                              isWide,
                            );
                          },
                        ),
                      ),

                      // 3. Dot Indicator (PageDots)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: PageDots(
                          count: _slides.length,
                          currentIndex: _currentPage,
                          onDotTapped: (index) {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            );
                          },
                        ),
                      ),

                      // 4. Bottom Sticky Action Area
                      _buildBottomActions(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const AppLogo(size: 32.0),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  AppConstants.appName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spaceXs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0,
                                  vertical: 1.0,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryFixed,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  'v1.0',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSecondaryFixed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Sahabat Sehat Anak Kos',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 10.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceXs),
              TextButton(
                onPressed: _finishOnboarding,
                style: TextButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 6.0,
                  ),
                ),
                child: Text(
                  'Lewati',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          // SDG Badges Bar
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SdgBadge.sdg3(),
                SizedBox(width: AppConstants.spaceXs),
                SdgBadge.sdg12(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(
    BuildContext context,
    OnboardingSlide slide,
    bool isWide,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final imageWidget = Container(
      height: isWide ? 260.0 : 170.0,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AssetImageWithFallback(
            assetPath: slide.imageAsset,
            fallbackIcon: Icons.restaurant,
            fit: BoxFit.cover,
          ),
          // Top Left Badge
          Positioned(
            top: 10.0,
            left: 10.0,
            right: 10.0,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest.withAlpha(230),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4.0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      slide.badgeIcon,
                      size: 14.0,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        slide.badgeText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Right Badge (if exists)
          if (slide.secondaryBadgeText != null)
            Positioned(
              bottom: 10.0,
              right: 10.0,
              left: 10.0,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (slide.secondaryBadgeIcon != null) ...[
                        Icon(
                          slide.secondaryBadgeIcon,
                          size: 14.0,
                          color: colorScheme.onTertiary,
                        ),
                        const SizedBox(width: 4.0),
                      ],
                      Flexible(
                        child: Text(
                          slide.secondaryBadgeText!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onTertiary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Label
        Text(
          slide.category,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2.0),
        // Title
        Text(
          slide.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            height: 1.25,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        // Bullets List
        ...slide.bullets.map((bullet) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28.0,
                    height: 28.0,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryFixed,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Icon(
                      bullet.icon,
                      size: 16.0,
                      color: colorScheme.onPrimaryFixed,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 4.0,
                          runSpacing: 2.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              bullet.title,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (bullet.sdgTag != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                  vertical: 1.0,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryFixedDim,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusSm,
                                  ),
                                ),
                                child: Text(
                                  bullet.sdgTag!,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onTertiaryFixed,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 1.0),
                        Text(
                          bullet.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10.5,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceXs,
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: imageWidget),
                const SizedBox(width: AppConstants.spaceLg),
                Expanded(flex: 6, child: textContent),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                imageWidget,
                const SizedBox(height: AppConstants.spaceSm),
                textContent,
              ],
            ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLastSlide = _currentPage == _slides.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceXs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary Button
          FilledButton(
            onPressed: isLastSlide ? _finishOnboarding : _nextPage,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: AppConstants.spaceMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastSlide
                        ? 'Mulai Rencanakan Makan (3 Menit)'
                        : 'Lanjut',
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Text(
                    isLastSlide ? '🚀' : '→',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4.0),

          // Secondary Demo Button
          TextButton(
            onPressed: _finishOnboarding,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
            child: Text(
              'Sudah punya data demo? Masuk Langsung',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Academic Footer Note
          Text(
            'Proyek Flutter MD3 • UTS & UAS Pemrograman Mobile\nTeknik Informatika • Indonesia Mandiri Sehat',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
              fontSize: 9.0,
            ),
          ),
          const SizedBox(height: 4.0),
        ],
      ),
    );
  }
}
