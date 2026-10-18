// Owner: Louis | FR: FR-02

enum WindowSize {
  compact,
  medium,
  expanded,
}

class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  static const double compactMax = 599.0;
  static const double mediumMin = 600.0;
  static const double mediumMax = 839.0;
  static const double expandedMin = 840.0;
}

/// Menentukan WindowSize berdasarkan lebar layar (width).
/// compact: < 600 dp, medium: 600 - 839 dp, expanded: >= 840 dp.
WindowSize windowSizeFor(double width) {
  if (width < ResponsiveBreakpoints.mediumMin) {
    return WindowSize.compact;
  }
  if (width < ResponsiveBreakpoints.expandedMin) {
    return WindowSize.medium;
  }
  return WindowSize.expanded;
}
