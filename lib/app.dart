// Owner: Louis | FR: FR-01, FR-03

import 'package:budget_bites/theme/app_theme.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:budget_bites/widgets/app_logo.dart';
import 'package:budget_bites/widgets/responsive_layout.dart';
import 'package:budget_bites/widgets/section_title.dart';
import 'package:flutter/material.dart';

class SmartBitesApp extends StatefulWidget {
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ThemeMode initialThemeMode;

  const SmartBitesApp({
    super.key,
    this.onThemeModeChanged,
    this.initialThemeMode = ThemeMode.system,
  });

  @override
  State<SmartBitesApp> createState() => _SmartBitesAppState();
}

class _SmartBitesAppState extends State<SmartBitesApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void _handleThemeModeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    widget.onThemeModeChanged?.call(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      // TEMP: Temporary preview page (Step 1b) for comparing with HTML at 390 px.
      // Dihapus pada Step 2 saat rute WelcomeScreen dan MainNavigation dipasang.
      home: TempStep1bPreviewPage(
        themeMode: _themeMode,
        onThemeModeChanged: _handleThemeModeChanged,
      ),
    );
  }
}

// ============================================================================
// TEMP: Step 1b Theme & Component Preview Page (Dihapus pada Step 2)
// Menampilkan Card, Chip, FilledButton, NavigationBar, Slider, dan SnackBar pada 390px.
// ============================================================================
class TempStep1bPreviewPage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const TempStep1bPreviewPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<TempStep1bPreviewPage> createState() => _TempStep1bPreviewPageState();
}

class _TempStep1bPreviewPageState extends State<TempStep1bPreviewPage> {
  double _sliderValue = 78.0; // 78% matching HTML budget progress bar
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartBites Theme Preview (390px)'),
        leading: const Padding(
          padding: EdgeInsets.all(AppConstants.spaceSm),
          child: AppLogo(size: 32),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) => setState(() => _navIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Belanja',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Air & Waste',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      body: ResponsiveLayout(
        compact: (context) => _buildPreviewContent(context, WindowSize.compact),
        medium: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.mobileTargetWidth, // 390px preview target
            ),
            child: _buildPreviewContent(context, WindowSize.medium),
          ),
        ),
        expanded: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.mobileTargetWidth, // 390px preview target
            ),
            child: _buildPreviewContent(context, WindowSize.expanded),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent(BuildContext context, WindowSize windowSize) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Theme Switcher Section
          SectionTitle(
            title: 'Mode Tema M3',
            trailing: Chip(
              label: Text(windowSize.name.toUpperCase()),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Wrap(
                spacing: AppConstants.spaceSm,
                runSpacing: AppConstants.spaceSm,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      Text(
                        isDark ? 'Mode Gelap' : 'Mode Terang',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: () {
                      widget.onThemeModeChanged(
                        isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                    child: Text(isDark ? 'Beralih ke Terang' : 'Beralih ke Gelap'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // 2. Plain Card & Chips
          const SectionTitle(title: 'Komponen Card & Chip'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Makan Minggu Ini',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text(
                    'Sisa budget: ${formatRupiah(65000)} dari ${formatRupiah(300000)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  Wrap(
                    spacing: AppConstants.spaceSm,
                    runSpacing: AppConstants.spaceXs,
                    children: [
                      Chip(
                        backgroundColor: theme.colorScheme.surfaceContainerLow,
                        label: Text(
                          'Hemat',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),
                      Chip(
                        backgroundColor: theme.colorScheme.secondaryContainer.withAlpha(50),
                        label: Text(
                          '7 Hari Streak 🔥',
                          style: TextStyle(color: theme.colorScheme.secondary),
                        ),
                      ),
                      Chip(
                        backgroundColor: theme.colorScheme.errorContainer,
                        avatar: Icon(
                          Icons.warning_amber_rounded,
                          size: 16.0,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        label: Text(
                          'Alergen Kacang',
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // 3. Slider (8px Gauge)
          SectionTitle(
            title: 'Slider Gauge (${_sliderValue.round()}%)',
            trailing: Text(
              '${_sliderValue.round()}%',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penggunaan Anggaran Mingguan',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  Slider(
                    value: _sliderValue,
                    min: 0.0,
                    max: 100.0,
                    onChanged: (val) => setState(() => _sliderValue = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // 4. SnackBar Test Action
          const SectionTitle(title: 'Floating SnackBar'),
          FilledButton.tonal(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Catatan berhasil diperbarui!'),
                  action: SnackBarAction(
                    label: 'Batalkan',
                    onPressed: () {},
                  ),
                ),
              );
            },
            child: const Text('Tampilkan SnackBar (Floating)'),
          ),
        ],
      ),
    );
  }
}
