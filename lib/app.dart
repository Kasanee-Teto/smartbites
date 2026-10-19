// Owner: Louis | FR: FR-01, FR-03

import 'package:budget_bites/screens/welcome_screen.dart';
import 'package:budget_bites/theme/app_theme.dart';
import 'package:budget_bites/utils/app_constants.dart';
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

  void handleThemeModeChanged(ThemeMode mode) {
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
      home: const WelcomeScreen(),
    );
  }
}
