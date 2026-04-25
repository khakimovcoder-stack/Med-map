import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum ShifoButtonVariant { primary, success, danger, ghost }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = ShifoButtonVariant.primary,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final ShifoButtonVariant variant;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final colors = _colorsFor(variant);

    final button = Material(
      color: isDisabled ? colors.bg.withValues(alpha: 0.5) : colors.bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isDisabled ? null : onPressed,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: variant == ShifoButtonVariant.ghost
                ? Border.all(color: AppColors.gray200)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.fg),
                  ),
                )
              else if (icon != null) ...[
                Icon(icon, size: 18, color: colors.fg),
                const SizedBox(width: 8),
              ],
              if (!isLoading)
                Text(
                  label,
                  style: TextStyle(
                    color: colors.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  _ButtonColors _colorsFor(ShifoButtonVariant v) {
    switch (v) {
      case ShifoButtonVariant.primary:
        return const _ButtonColors(AppColors.bluePrimary, Colors.white);
      case ShifoButtonVariant.success:
        return const _ButtonColors(AppColors.greenSuccess, Colors.white);
      case ShifoButtonVariant.danger:
        return const _ButtonColors(AppColors.redDanger, Colors.white);
      case ShifoButtonVariant.ghost:
        return const _ButtonColors(Colors.transparent, AppColors.textPrimary);
    }
  }
}

class _ButtonColors {
  const _ButtonColors(this.bg, this.fg);
  final Color bg;
  final Color fg;
}
