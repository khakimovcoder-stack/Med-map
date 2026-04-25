import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Small pill showing a count of available beds with a colored dot.
class AvailabilityBadge extends StatelessWidget {
  const AvailabilityBadge({
    super.key,
    required this.availableBeds,
    this.compact = false,
  });

  final int availableBeds;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isAvailable = availableBeds > 0;
    final color = isAvailable ? AppColors.greenSuccess : AppColors.redDanger;
    final bg = isAvailable ? AppColors.greenLight : AppColors.redLight;
    final label = isAvailable ? '$availableBeds ta bo\'sh joy' : 'To\'liq band';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color.computeLuminance() < 0.5
                  ? color
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
