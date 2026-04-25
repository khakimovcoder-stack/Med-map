import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/bed.dart';

/// Renders a single bed inside the 2D room visual.
class BedTile extends StatelessWidget {
  const BedTile({
    super.key,
    required this.bed,
    this.isSelf = false,
    this.selectedStatus,
    this.onTap,
    this.compact = false,
  });

  /// Underlying bed (current_status may be overridden by [selectedStatus]).
  final Bed bed;

  /// Mark this bed as the current user's own (thick blue border + "Meniki").
  final bool isSelf;

  /// When non-null, displays this status instead of [bed.currentStatus]
  /// (used during patient confirmation flow).
  final String? selectedStatus;

  final VoidCallback? onTap;

  /// Smaller layout for the room detail viewer.
  final bool compact;

  Color _statusColor(String status) => AppColors.statusBg(status);
  Color _statusBg(String status) => AppColors.statusBgLight(status);

  IconData _statusIcon(String status) {
    switch (status) {
      case BedStatus.band:
        return LucideIcons.bed;
      case BedStatus.bosh:
        return LucideIcons.checkCircle2;
      default:
        return LucideIcons.helpCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = selectedStatus ?? bed.currentStatus;
    final accent = _statusColor(status);
    final bg = _statusBg(status);
    final theme = Theme.of(context);

    final selfBorder = isSelf
        ? Border.all(color: AppColors.bluePrimary, width: 3)
        : Border.all(color: accent, width: 2);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: compact ? 76 : 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: selfBorder,
          ),
          child: Stack(
            children: [
              // position number
              Positioned(
                top: 0,
                left: 0,
                child: Text(
                  '${bed.position}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // window star
              if (bed.isNearWindow)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    LucideIcons.star,
                    size: 12,
                    color: AppColors.bluePrimary,
                  ),
                ),
              // body
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(status), color: accent, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      isSelf
                          ? 'Meniki'
                          : BedStatus.labelUz(status),
                      style: TextStyle(
                        color: isSelf ? AppColors.bluePrimary : accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
