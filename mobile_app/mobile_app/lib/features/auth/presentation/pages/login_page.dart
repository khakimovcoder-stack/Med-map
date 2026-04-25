import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/oneid_modal.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Kirish'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.bluePrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.shieldCheck,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'OneID orqali tasdiqlang',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Bemor sifatida palata holatini tasdiqlash uchun '
                'davlat identifikatsiya tizimi orqali kirish kerak.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray500,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'OneID orqali kirish',
                icon: LucideIcons.shieldCheck,
                onPressed: () async {
                  final session = await showOneIdModal(context);
                  if (session != null && context.mounted) {
                    context.go('/');
                  }
                },
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Bekor qilish',
                variant: ShifoButtonVariant.ghost,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
