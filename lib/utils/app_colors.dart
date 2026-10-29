// Owner: Louis | FR: FR-03

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 1. Primary Seed & Brand Green (from HTML tailwind.config
  // 'primary-container' & 'primary')
  static const Color seedColor = Color(0xFF2E7D32); // Emerald leaf green
  static const Color primaryDarkGreen = Color(0xFF0D631B); // HTML 'primary'

  // 2. Surface & Background Roles (from HTML body 'bg-surface' & cards
  // 'bg-surface-container-lowest')
  static const Color surfaceLight = Color(
    0xFFF5FBF1,
  ); // HTML 'surface' (#f5fbf1)
  static const Color surfaceDark = Color(
    0xFF121812,
  ); // Dark mode surface (#121812)
  static const Color cardSurfaceLight = Color(
    0xFFFFFFFF,
  ); // HTML 'surface-container-lowest' (#ffffff)
  static const Color cardSurfaceDark = Color(
    0xFF1B241C,
  ); // Dark container surface (#1b241c)
  static const Color surfaceContainerLow = Color(
    0xFFEFF6EB,
  ); // HTML 'bg-surface-container-low'
  static const Color surfaceContainerHighest = Color(
    0xFFDEE4DA,
  ); // HTML 'bg-surface-container-highest'

  // 3. Hydration & Secondary Accents (from HTML 'tertiary' water cards &
  // 'secondary' streaks)
  static const Color hydrationBlue = Color(
    0xFF005A8C,
  ); // HTML 'tertiary' (#005a8c)
  static const Color hydrationContainer = Color(
    0xFFCEE5FF,
  ); // HTML 'tertiary-fixed' (#cee5ff)
  static const Color harvestAmber = Color(
    0xFF964900,
  ); // HTML 'secondary' (#964900)
  static const Color harvestAmberContainer = Color(
    0xFFFFDCC6,
  ); // HTML 'secondary-fixed' (#ffdcc6)

  // 4. Alerts & Urgent Semantic Colors (from HTML allergy chip & zero waste)
  static const Color alertTerracotta = Color(
    0xFFD84315,
  ); // HTML shelf-life warning
  static const Color errorRed = Color(0xFFBA1A1A); // HTML 'error' (#ba1a1a)
  static const Color errorLight = Color(
    0xFFFFB4AB,
  ); // High-contrast salmon/pink for dark mode
  static const Color errorContainer = Color(
    0xFFFFDAD6,
  ); // HTML 'error-container' (#ffdad6)
  static const Color errorContainerDark = Color(
    0xFF93000A,
  ); // HTML dark mode error container
  static const Color onErrorContainerLight = Color(
    0xFF93000A,
  ); // High-contrast deep red text on light pink
  static const Color onErrorContainerDark = Color(
    0xFFFFDAD6,
  ); // High-contrast soft pink text on deep red
}
