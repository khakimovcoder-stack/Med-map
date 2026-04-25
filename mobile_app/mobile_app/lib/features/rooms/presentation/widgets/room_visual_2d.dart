import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/bed.dart';
import 'bed_tile.dart';

/// 2D top-down view of a 4-bed room: window strip on top, beds in 2x2 grid,
/// door strip on the bottom.
class RoomVisual2D extends StatelessWidget {
  const RoomVisual2D({
    super.key,
    required this.beds,
    this.selfBedId,
    this.selectedStatuses = const {},
    this.onBedTap,
    this.compact = false,
  });

  final List<Bed> beds;

  /// Bed marked as "Meniki" (the current patient's own bed).
  final String? selfBedId;

  /// Map of bed.id → status override, used during confirmation flow.
  final Map<String, String> selectedStatuses;

  final void Function(Bed bed)? onBedTap;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Sort by position to guarantee 1,2,3,4 layout.
    final sorted = [...beds]..sort((a, b) => a.position.compareTo(b.position));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        children: [
          const _WindowStrip(),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: compact ? 1.4 : 1.2,
            children: sorted.map((bed) {
              final selected = selectedStatuses[bed.id];
              return BedTile(
                bed: bed,
                compact: compact,
                isSelf: selfBedId == bed.id,
                selectedStatus: selected,
                onTap: onBedTap == null ? null : () => onBedTap!(bed),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 16),
          const _DoorStrip(),
        ],
      ),
    );
  }
}

class _WindowStrip extends StatelessWidget {
  const _WindowStrip();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.blueSecondary,
                AppColors.bluePrimary,
                AppColors.blueSecondary,
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'DERAZA',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}

class _DoorStrip extends StatelessWidget {
  const _DoorStrip();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'ESHIK',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
            color: AppColors.gray500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
