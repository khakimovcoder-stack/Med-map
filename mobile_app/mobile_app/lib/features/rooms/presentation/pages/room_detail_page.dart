import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shifo_card.dart';
import '../../data/models/bed.dart';
import '../../data/models/room.dart';
import '../../providers/room_providers.dart';
import '../widgets/room_visual_2d.dart';

class RoomDetailPage extends ConsumerWidget {
  const RoomDetailPage({super.key, required this.roomId});
  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(roomDetailProvider(roomId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: async.maybeWhen(
          data: (d) => Text('${d.number}-palata'),
          orElse: () => const Text('Palata'),
        ),
      ),
      body: async.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            LoadingSkeleton(height: 360, radius: 16),
            SizedBox(height: 16),
            LoadingSkeleton(height: 80),
            SizedBox(height: 12),
            LoadingSkeleton(height: 80),
          ],
        ),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(roomDetailProvider(roomId)),
        ),
        data: (room) => _RoomContent(room: room),
      ),
    );
  }
}

class _RoomContent extends StatelessWidget {
  const _RoomContent({required this.room});
  final RoomDetail room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress =
        room.totalBeds == 0 ? 0.0 : room.availableBeds / room.totalBeds;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Context
        Text(
          '${room.hospital.shortName} • ${room.floor.number}-qavat',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${room.number}-palata',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: AppColors.bluePrimary,
          ),
        ),
        const SizedBox(height: 16),

        // 2D visual
        RoomVisual2D(beds: room.beds),

        const SizedBox(height: 16),

        // Availability summary
        ShifoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${room.availableBeds} / ${room.totalBeds}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.bluePrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'bo\'sh joy',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.gray100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.greenSuccess,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (room.confirmationSummary != null) ...[
                _SummaryRow(
                  icon: LucideIcons.clock,
                  label: minutesAgoUz(
                    room.confirmationSummary!.minutesSinceUpdate,
                  ),
                  sublabel: 'oxirgi yangilanish',
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  icon: LucideIcons.users,
                  label:
                      '${room.confirmationSummary!.uniqueUsers24h} bemor tomonidan tasdiqlangan',
                  sublabel: 'oxirgi 24 soat',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Per-bed list
        Text('Karavotlar', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...([...room.beds]..sort((a, b) => a.position.compareTo(b.position)))
            .map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _BedRow(bed: b),
          ),
        ),

        const SizedBox(height: 16),

        ShifoCard(
          background: AppColors.blue50,
          borderColor: AppColors.blueLight,
          child: Row(
            children: [
              const Icon(
                LucideIcons.qrCode,
                color: AppColors.bluePrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bu xonadasiz? Eshikdagi QR kodni skaner qiling — ma\'lumotni siz ham yangilashingiz mumkin.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.bluePrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Ushbu xonani QR orqali tasdiqlash',
          icon: LucideIcons.qrCode,
          variant: ShifoButtonVariant.ghost,
          onPressed: () => context.push('/scan'),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.sublabel,
  });
  final IconData icon;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: '  $sublabel',
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BedRow extends StatelessWidget {
  const _BedRow({required this.bed});
  final Bed bed;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusBg(bed.currentStatus);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${bed.position}',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Karavot ${bed.position}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (bed.isNearWindow) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        LucideIcons.star,
                        size: 12,
                        color: AppColors.bluePrimary,
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        'deraza yonida',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.bluePrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${minutesAgoUz(bed.lastConfirmedAt == null ? null : DateTime.now().difference(bed.lastConfirmedAt!.toLocal()).inMinutes)} • ${bed.confirmationCount} tasdiq',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              BedStatus.labelUz(bed.currentStatus),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
