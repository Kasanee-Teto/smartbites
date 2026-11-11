// Owner: Louis | FR: FR-01, FR-03

import 'package:budget_bites/i18n/generated/app_localizations.dart';
import 'package:budget_bites/screens/welcome_screen.dart';
import 'package:budget_bites/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SmartBitesApp extends StatefulWidget {
  const SmartBitesApp({
    super.key,
    this.onThemeModeChanged,
    this.initialThemeMode = ThemeMode.system,
    this.locale = const Locale('id'),
  });
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ThemeMode initialThemeMode;
  final Locale locale;

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

  void handleThemeModeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    widget.onThemeModeChanged?.call(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      locale: widget.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: WelcomeScreen(onThemeModeChanged: handleThemeModeChanged),
    );
  }
}
