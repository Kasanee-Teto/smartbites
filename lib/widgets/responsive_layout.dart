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
        final windowSize = windowSizeFor(constraints.maxWidth);
        switch (windowSize) {
          case WindowSize.expanded:
            if (expanded != null) {
              return expanded!(context);
            }
            if (medium != null) {
              return medium!(context);
            }
            return compact(context);
          case WindowSize.medium:
            if (medium != null) {
              return medium!(context);
            }
            return compact(context);
          case WindowSize.compact:
            return compact(context);
        }
      },
    );
  }
}
