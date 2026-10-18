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
      // TEMP: Temporary debug page for Step 1 foundation validation.
      // Akan diganti dengan WelcomeScreen/MainNavigation pada Step 2.
      home: TempStep1DebugPage(
        themeMode: _themeMode,
        onThemeModeChanged: _handleThemeModeChanged,
      ),
    );
  }
}

// ============================================================================
// TEMP: Step 1 Debug Page (Dihapus pada Step 2)
// Menampilkan validasi 3 window sizes, 2 themes, AppLogo, dan SectionTitle.
// ============================================================================
class TempStep1DebugPage extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const TempStep1DebugPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartBites Foundation'),
        leading: const Padding(
          padding: EdgeInsets.all(AppConstants.spaceSm),
          child: AppLogo(size: 32),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxContentWidth,
          ),
          child: ResponsiveLayout(
            compact: (context) => _buildContent(context, WindowSize.compact),
            medium: (context) => _buildContent(context, WindowSize.medium),
            expanded: (context) => _buildContent(context, WindowSize.expanded),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WindowSize windowSize) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(
            title: 'Window Size Status',
            trailing: Chip(
              label: Text(windowSize.name.toUpperCase()),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Text(
                'Layout aktif: ${windowSize.name} (${windowSize == WindowSize.compact ? "<600dp" : windowSize == WindowSize.medium ? "600-839dp" : ">=840dp"})',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          SectionTitle(
            title: 'Pengaturan Tema (M3)',
            trailing: IconButton(
              tooltip: 'Tampilkan info SnackBar',
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tema Material 3 aktif dan responsif!'),
                  ),
                );
              },
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
                        'Mode: ${isDark ? "Gelap" : "Terang"}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: () {
                      onThemeModeChanged(
                        isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                    child: Text(isDark ? 'Ganti ke Terang' : 'Ganti ke Gelap'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          const SectionTitle(title: 'Komponen & Formatter'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      AppLogo(size: 40),
                      SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: Text('AppLogo dengan fallback icon Icons.eco'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  Text('Uji formatRupiah: ${formatRupiah(25000)} | Negatif: ${formatRupiah(-15000)}'),
                  Text('Uji dateOnly: ${dateOnly(DateTime.now())}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
