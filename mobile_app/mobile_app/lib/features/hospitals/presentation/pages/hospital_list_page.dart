import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../providers/hospital_providers.dart';
import '../widgets/hospital_card.dart';
import '../widgets/hospital_search_bar.dart';

class HospitalListPage extends ConsumerWidget {
  const HospitalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsAsync = ref.watch(hospitalListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(2),
              child: Image.asset(
                'assets/images/icon.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MED MAP',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.bluePrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Shaffof shifoxona',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'QR skaner',
            icon: const Icon(LucideIcons.qrCode),
            onPressed: () => context.push('/scan'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(hospitalListProvider);
          await ref.read(hospitalListProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: HospitalSearchBar(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  'Shifoxonalar',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            ),
            hospitalsAsync.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: 3,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, _) => const HospitalCardSkeleton(),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: ErrorView(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(hospitalListProvider),
                ),
              ),
              data: (hospitals) {
                if (hospitals.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyState(
                      title: 'Shifoxona topilmadi',
                      message: 'Boshqa qidiruv so\'zini sinab ko\'ring',
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: hospitals.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final h = hospitals[i];
                      return HospitalCard(
                        hospital: h,
                        onTap: () => context.push('/hospitals/${h.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scan'),
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(LucideIcons.qrCode),
        label: const Text('QR skaner'),
      ),
    );
  }
}
