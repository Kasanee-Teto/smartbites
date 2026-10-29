// Owner: Louis | FR: FR-03, FR-04, FR-22, FR-26

class AppConstants {
  AppConstants._();

  static const String appName = 'SmartBites';
  static const int defaultWeeklyBudget = 300000;
  static const int defaultWaterTargetMl = 2000;

  // Spacing scale (dp) - Mapped 1:1 from HTML tailwind.config spacing
  static const double spaceXs = 4; // HTML 'space-xs' (0.25rem)
  static const double spaceSm = 8; // HTML 'space-sm' (0.5rem)
  static const double spaceMd = 16; // HTML 'space-md' (1rem)
  static const double spaceLg = 24; // HTML 'space-lg' (1.5rem)
  static const double spaceXl = 32; // HTML 'space-xl' (2rem)
  static const double spaceXxl = 48; // HTML sectional spacing

  // Radii scale (dp) - Mapped 1:1 from HTML tailwind.config borderRadius
  static const double radiusSm = 4; // HTML 'DEFAULT' (0.25rem)
  static const double radiusDefault = 8; // HTML 'lg' (0.5rem)
  static const double radiusMd = 12; // HTML 'xl' (0.75rem - Cards)
  static const double radiusLg = 16; // HTML '2xl' (1rem)
  static const double radiusXl = 24; // HTML '3xl' (1.5rem - Bottom Sheet)
  static const double radiusFull = 9999; // HTML 'full' (Pills & Buttons)

  // Layout & Touch constraints
  static const double maxContentWidth = 1100;
  static const double mobileTargetWidth = 390; // HTML mobile target width
  static const double minTouchTarget = 48; // Accessibility minimum tap target
}
