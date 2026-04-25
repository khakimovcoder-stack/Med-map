import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/shifo_card.dart';
import '../../data/models/hospital.dart';

class FloorCard extends StatelessWidget {
  const FloorCard({
    super.key,
    required this.floor,
    required this.onTap,
  });

  final FloorSummary floor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFull = floor.availableBeds == 0;
    final accent = isFull ? AppColors.redDanger : AppColors.greenSuccess;
    final progress = floor.totalBeds == 0
        ? 0.0
        : floor.availableBeds / floor.totalBeds;

    return ShifoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${floor.number}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${floor.number}-qavat',
                  style: theme.textTheme.titleMedium,
                ),
                if (floor.name != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    floor.name!,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      isFull
                          ? 'To\'liq band'
                          : '${floor.availableBeds} ta bo\'sh joy',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ ${floor.totalBeds}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.gray100,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            LucideIcons.chevronRight,
            color: AppColors.gray500,
            size: 20,
          ),
        ],
      ),
    );
  }
}
