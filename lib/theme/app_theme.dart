// Owner: Louis | FR: FR-03

import 'package:budget_bites/utils/app_colors.dart';
import 'package:budget_bites/utils/app_constants.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // Generate base Material 3 palette from Emerald seed color
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: brightness,
    );

    // Apply exact HTML design overrides where seed generation differs slightly
    final colorScheme = baseColorScheme.copyWith(
      surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      surfaceContainerLowest: isDark ? AppColors.cardSurfaceDark : AppColors.cardSurfaceLight,
      surfaceContainerHighest: isDark ? const Color(0xFF2C322B) : AppColors.surfaceContainerHighest,
      primary: isDark ? const Color(0xFF88D982) : AppColors.primaryDarkGreen,
      primaryContainer: AppColors.seedColor,
      secondary: isDark ? const Color(0xFFFFB786) : AppColors.harvestAmber,
      secondaryContainer: isDark ? const Color(0xFF5E2C00) : const Color(0xFFFC820C),
      tertiary: isDark ? const Color(0xFF96CCFF) : AppColors.hydrationBlue,
      error: isDark ? AppColors.errorLight : AppColors.errorRed,
      errorContainer: isDark ? AppColors.errorContainerDark : AppColors.errorContainer,
      onError: isDark ? const Color(0xFF690005) : Colors.white,
      onErrorContainer: isDark ? AppColors.onErrorContainerDark : AppColors.onErrorContainerLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _buildTextTheme(colorScheme),
      // 1. Plain Card: pure white background in light mode, rounded 12dp (HTML rounded-xl)
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          side: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(50),
            width: 1.0,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      // 2. Chip: pill shape (rounded-full), compact 32dp height
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        labelStyle: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      ),
      // 3. FilledButton: full pill geometry, 48dp touch target
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            AppConstants.minTouchTarget,
            AppConstants.minTouchTarget,
          ),
          shape: const StadiumBorder(),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // 4. NavigationBar: 72dp operational clearance, primaryContainer pill indicator
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer.withAlpha(60),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      // 5. NavigationRail for expanded screens
      navigationRailTheme: NavigationRailThemeData(
        indicatorColor: colorScheme.primaryContainer.withAlpha(60),
        minWidth: 72,
      ),
      // 6. Slider: 8px gauge height with pill thumb matching Design.md
      sliderTheme: SliderThemeData(
        trackHeight: 8.0,
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
      ),
      // 7. SnackBar: floating so it clears the FAB, rounded-lg (8dp)
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
        ),
      ),
      // 8. InputDecoration: 8dp radius outline with surfaceContainerHighest fill
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: AppConstants.spaceSm,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 40.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: colorScheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.32,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.14,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.24,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.33,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
