// Owner: Louis | FR: FR-01, FR-03

import 'package:budget_bites/screens/welcome_screen.dart';
import 'package:budget_bites/theme/app_theme.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:flutter/material.dart';

class SmartBitesApp extends StatelessWidget {
  const SmartBitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const WelcomeScreen(),
    );
  }
}
