import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../providers/room_providers.dart';
import '../widgets/room_card.dart';

class FloorRoomsPage extends ConsumerWidget {
  const FloorRoomsPage({super.key, required this.floorId});
  final String floorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(floorRoomsProvider(floorId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: async.maybeWhen(
          data: (d) => Text('${d.floor.number}-qavat'),
          orElse: () => const Text('Qavat'),
        ),
      ),
      body: async.when(
        loading: () => GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: List.generate(
            6,
            (_) => const LoadingSkeleton(height: 140, radius: 12),
          ),
        ),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(floorRoomsProvider(floorId)),
        ),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(floorRoomsProvider(floorId));
              await ref.read(floorRoomsProvider(floorId).future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.floor.hospitalName != null)
                          Text(
                            data.floor.hospitalName!,
                            style: theme.textTheme.bodySmall,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          data.floor.name ?? '${data.floor.number}-qavat',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.rooms.length} ta palata',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        const _LegendRow(),
                      ],
                    ),
                  ),
                ),
                if (data.rooms.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      title: 'Palatalar topilmadi',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final r = data.rooms[i];
                          return RoomCard(
                            room: r,
                            onTap: () => context.push('/rooms/${r.id}'),
                          );
                        },
                        childCount: data.rooms.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendDot(color: AppColors.greenSuccess, label: 'Bo\'sh joy bor'),
        SizedBox(width: 16),
        _LegendDot(color: AppColors.redDanger, label: 'To\'liq band'),
        SizedBox(width: 16),
        _LegendDot(color: AppColors.grayUnknown, label: 'Noma\'lum'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}
