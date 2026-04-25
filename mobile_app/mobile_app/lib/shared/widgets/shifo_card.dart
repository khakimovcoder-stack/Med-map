import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Standard surface card. Padding 16/20, radius 12, gray-100 border, optional tap.
class ShifoCard extends StatelessWidget {
  const ShifoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.onTap,
    this.borderColor,
    this.borderWidth = 1,
    this.background,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: borderColor ?? AppColors.gray100,
        width: borderWidth,
      ),
    );

    return Material(
      color: background ?? AppColors.surface,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
