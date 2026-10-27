// Owner: Louis | FR: FR-01, FR-03

import 'package:flutter/material.dart';

/// Renders a local asset image if available; otherwise falls back gracefully
/// to an error builder container with a themed icon and subtle surface tint.
class AssetImageWithFallback extends StatelessWidget {
  final String assetPath;
  final IconData fallbackIcon;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AssetImageWithFallback({
    super.key,
    required this.assetPath,
    this.fallbackIcon = Icons.eco,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget imageWidget = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: colorScheme.surfaceContainerLow,
          alignment: Alignment.center,
          child: Icon(
            fallbackIcon,
            size: (height != null && height! < 60) ? 24.0 : 44.0,
            color: colorScheme.primary.withAlpha(180),
          ),
        );
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
