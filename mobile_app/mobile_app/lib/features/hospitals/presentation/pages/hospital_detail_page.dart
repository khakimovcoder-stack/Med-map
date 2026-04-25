import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/shifo_card.dart';
import '../../providers/hospital_providers.dart';
import '../widgets/floor_card.dart';

class HospitalDetailPage extends ConsumerWidget {
  const HospitalDetailPage({super.key, required this.hospitalId});

  final String hospitalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(hospitalDetailProvider(hospitalId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const _BackButton(),
        title: detailAsync.maybeWhen(
          data: (d) => Text(
            d.hospital.shortName.isNotEmpty
                ? d.hospital.shortName
                : d.hospital.name,
          ),
          orElse: () => const Text('Shifoxona'),
        ),
      ),
      body: detailAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            LoadingSkeleton(height: 140, radius: 16),
            SizedBox(height: 16),
            LoadingSkeleton(height: 80),
            SizedBox(height: 12),
            LoadingSkeleton(height: 80),
            SizedBox(height: 12),
            LoadingSkeleton(height: 80),
            SizedBox(height: 12),
            LoadingSkeleton(height: 80),
          ],
        ),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(hospitalDetailProvider(hospitalId)),
        ),
        data: (detail) {
          final h = detail.hospital;
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(hospitalDetailProvider(hospitalId));
              await ref.read(hospitalDetailProvider(hospitalId).future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // Hero card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.bluePrimary,
                        AppColors.blueSecondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              LucideIcons.building2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              h.shortName.isNotEmpty ? h.shortName : h.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        h.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _HeroInfoRow(
                        icon: LucideIcons.mapPin,
                        text: '${h.city} • ${h.address}',
                      ),
                      const SizedBox(height: 6),
                      _HeroInfoRow(icon: LucideIcons.phone, text: h.phone),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _HeroStat(
                              value: '${h.availableBeds}',
                              label: 'bo\'sh joy',
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          Expanded(
                            child: _HeroStat(
                              value: '${h.totalBeds}',
                              label: 'jami karavot',
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Qavatlar',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                ...detail.floors.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FloorCard(
                      floor: f,
                      onTap: () => context.push('/floors/${f.id}'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ShifoCard(
                  background: AppColors.blue50,
                  borderColor: AppColors.blueLight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.info,
                        color: AppColors.bluePrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bo\'sh joy soni bemorlar tomonidan tasdiqlangan ma\'lumotlarga asoslangan.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.bluePrimary,
                          ),
                        ),
                      ),
                    ],
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

class _HeroInfoRow extends StatelessWidget {
  const _HeroInfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.95),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(LucideIcons.arrowLeft),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
    );
  }
}
