// Owner: Louis | FR: FR-02

import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:flutter/material.dart';

typedef ResponsiveWidgetBuilder = Widget Function(BuildContext context);

class ResponsiveLayout extends StatelessWidget {
  final ResponsiveWidgetBuilder compact;
  final ResponsiveWidgetBuilder? medium;
  final ResponsiveWidgetBuilder? expanded;

  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.expandedMin &&
            expanded != null) {
          return expanded!(context);
        }
        if (constraints.maxWidth >= ResponsiveBreakpoints.mediumMin &&
            medium != null) {
          return medium!(context);
        }
        return compact(context);
      },
    );
  }
}
