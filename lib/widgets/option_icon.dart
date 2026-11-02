// Owner: Jessica | Colorful option and nutrition markers.

import 'package:flutter/material.dart';

class OptionIcon extends StatelessWidget {
  const OptionIcon({
    required this.icon,
    required this.color,
    this.size = 32,
    super.key,
  });
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(icon, color: color, size: size * 0.6),
    ),
  );
}
