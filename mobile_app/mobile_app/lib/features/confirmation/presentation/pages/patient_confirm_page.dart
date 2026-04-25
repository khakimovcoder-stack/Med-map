import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/shifo_card.dart';
import '../../../auth/presentation/widgets/oneid_modal.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../rooms/data/models/bed.dart';
import '../../../rooms/data/models/room.dart';
import '../../../rooms/providers/room_providers.dart';
import '../../data/confirmation_repository.dart';
import '../../providers/confirmation_providers.dart';

class PatientConfirmPage extends ConsumerWidget {
  const PatientConfirmPage({super.key, required this.roomId});
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
        title: const Text('Joy band qilish'),
      ),
      body: async.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            LoadingSkeleton(height: 60),
            SizedBox(height: 16),
            LoadingSkeleton(height: 320, radius: 16),
          ],
        ),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(roomDetailProvider(roomId)),
        ),
        data: (room) => _ClaimBody(room: room),
      ),
    );
  }
}

class _ClaimBody extends ConsumerStatefulWidget {
  const _ClaimBody({required this.room});
  final RoomDetail room;

  @override
  ConsumerState<_ClaimBody> createState() => _ClaimBodyState();
}

class _ClaimBodyState extends ConsumerState<_ClaimBody> {
  bool _submitting = false;

  bool _isFree(Bed b) => b.currentStatus != BedStatus.band;

  Future<void> _submit() async {
    final draft = ref.read(claimDraftProvider);
    if (draft.selectedBedId == null) {
      _showError('Avval bitta bo\'sh karavotni tanlang.');
      return;
    }

    final auth = ref.read(authControllerProvider).value;
    if (auth == null || !auth.isAuthenticated) {
      final session = await showOneIdModal(context);
      if (session == null) return;
    }

    setState(() => _submitting = true);
    try {
      final claim = ref.read(claimBedProvider);
      final result = await claim(draft.selectedBedId!);
      ref.invalidate(roomDetailProvider(widget.room.id));
      if (!mounted) return;
      await _showSuccess(result);
      if (!mounted) return;
      context.pop();
    } on Exception catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.redDanger,
      ),
    );
  }

  Future<void> _showSuccess(ClaimResult result) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                LucideIcons.checkCircle2,
                color: AppColors.greenSuccess,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              result.alreadyClaimed ? 'Allaqachon band' : 'Tabriklaymiz!',
              style: Theme.of(ctx).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              result.message,
              style: Theme.of(ctx).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Karavot ${result.position} • Palata ${result.roomNumber}',
              style: Theme.of(ctx).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            label: 'Yopish',
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final draft = ref.watch(claimDraftProvider);
    final controller = ref.read(claimDraftProvider.notifier);
    final beds = [...widget.room.beds]
      ..sort((a, b) => a.position.compareTo(b.position));
    final freeCount = beds.where(_isFree).length;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
          children: [
            Text('Siz', style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              '${widget.room.floor.number}-qavat, '
              '${widget.room.number}-palata',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: AppColors.bluePrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.room.hospital.name,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            Text(
              'O\'zingizga karavot tanlang',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              freeCount == 0
                  ? 'Afsus, bu palatada bo\'sh karavot qolmagan.'
                  : 'Bo\'sh karavotlardan birini tanlang. '
                      'Faqat o\'zingiz uchun band qilasiz.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: beds.map((bed) {
                final free = _isFree(bed);
                final selected = draft.selectedBedId == bed.id;
                return _ClaimBedTile(
                  bed: bed,
                  isFree: free,
                  isSelected: selected,
                  onTap: free
                      ? () => selected
                          ? controller.clear()
                          : controller.select(bed.id)
                      : null,
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            ShifoCard(
              background: AppColors.yellowLight,
              borderColor: AppColors.yellowWarning.withValues(alpha: 0.3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.shieldAlert,
                    color: AppColors.yellowWarning,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.gray900,
                          height: 1.4,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Diqqat: ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text:
                                'Siz faqat o\'zingiz uchun bitta karavotni '
                                'band qila olasiz. Ma\'lumotlaringiz OneID '
                                'orqali tasdiqlanadi. Yolg\'on band qilish '
                                'qonuniy javobgarlikka sabab bo\'lishi mumkin.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.gray100)),
            ),
            child: SafeArea(
              top: false,
              child: PrimaryButton(
                label: 'Joyni Band Qilish',
                icon: LucideIcons.shieldCheck,
                isLoading: _submitting,
                variant: ShifoButtonVariant.success,
                onPressed: (_submitting || !draft.hasSelection || freeCount == 0)
                    ? null
                    : _submit,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClaimBedTile extends StatelessWidget {
  const _ClaimBedTile({
    required this.bed,
    required this.isFree,
    required this.isSelected,
    required this.onTap,
  });

  final Bed bed;
  final bool isFree;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color borderColor;
    final Color bg;
    final Color fg;
    final IconData icon;
    final String label;

    if (!isFree) {
      borderColor = AppColors.redDanger;
      bg = AppColors.redLight;
      fg = AppColors.redDanger;
      icon = LucideIcons.bed;
      label = 'Band';
    } else if (isSelected) {
      borderColor = AppColors.bluePrimary;
      bg = AppColors.blueLight;
      fg = AppColors.bluePrimary;
      icon = LucideIcons.user;
      label = 'Meniki';
    } else {
      borderColor = AppColors.greenSuccess;
      bg = AppColors.greenLight;
      fg = AppColors.greenSuccess;
      icon = LucideIcons.checkCircle2;
      label = 'Bo\'sh';
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: isSelected ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Text(
                  '${bed.position}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (bed.isNearWindow)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.star,
                        size: 12,
                        color: AppColors.bluePrimary,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'deraza',
                        style: TextStyle(
                          color: AppColors.bluePrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: fg, size: 26),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
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
