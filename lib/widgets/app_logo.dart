// Owner: Louis | FR: FR-01, FR-03

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 48.0});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback ikon ramah lingkungan jika aset gambar belum tersedia
        return Icon(
          Icons.eco,
          size: size,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}
